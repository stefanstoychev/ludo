import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import '../board_data.dart';

import '../collections.dart';
import '../model/pawn.dart';

class PlayerService with ChangeNotifier {
  PlayerService({required this.session, required this.board});

  final String session;

  final BoardData board;

  final List<Pawn> pawns = [];

  final List<String> playerIds = [];
  String? gameId;

  String? currentPLayer;

  int getIndex(String playerId) {
    return playerIds.indexOf(playerId);
  }

  void setGameId(String gameId) {
    this.gameId = gameId;
  }

  void addPlayer(String playerId) {
    playerIds.add(playerId);

    notifyListeners();
  }

  void addPawn(String pawnId, String ownerId, int number) {
    var playerIndex = getIndex(ownerId);

    var first = board.playerPaths[playerIndex].first;

    var x = first[0];
    var y = first[1];

    var pawn = Pawn(id: pawnId, ownerId: ownerId, x: x, y: y, position: 0, number: number);

    pawns.add(pawn);

    notifyListeners();
  }

  void movePawn(String pawnId, int position) {
    var pawn = pawns.firstWhere((element) => element.id == pawnId);

    var playerIndex = getIndex(pawn.ownerId);

    var currentPoss = board.playerPaths[playerIndex][position];

    pawn.x = currentPoss[0];
    pawn.y = currentPoss[1];
    pawn.position = position;

    if(position != 0)
      _handleCollisions(pawn.ownerId, pawn.x, pawn.y);

    notifyListeners();
  }

  void currentPlayer(String playerId) {
    currentPLayer = playerId;

    notifyListeners();
  }

  Future<void> _handleCollisions(String playerId, int x, int y) async {

    var enemyPawns = pawns.where((element) => element.ownerId != playerId);

    var collisions = enemyPawns.where((element) => element.x == x && element.y == y);

    for(var collision in collisions){

      var apiResponse = await ParseObject(pawnCollection).getObject(collision.id);

      if (apiResponse.success && apiResponse.results != null) {
        for (var o in apiResponse.results) {
          final pawn = o as ParseObject;
          pawn.set("Position", 0);

          await pawn.save();
        }
      }
    }
  }

}
