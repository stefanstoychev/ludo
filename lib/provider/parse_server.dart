import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../collections.dart';
import '../model/pawn.dart';
import '../settings.dart';
import 'player_service.dart';

class ParseServer with ChangeNotifier {

  Future<Parse> initializeParse() {
    Settings settings = kDebugMode ? LocalSettings() : ProdSettings();

    return Parse().initialize(
      settings.keyApplicationId,
      settings.keyParseServerUrl,
      liveQueryUrl: settings.keyLivequeryUrl,
      clientKey: settings.clientKey,
      debug: false,
      autoSendSessionId: true,
    );
  }

  Future<void> resetPawn(String id) async {
    var apiResponse = await ParseObject(pawnCollection).getObject(id);

    if (apiResponse.success && apiResponse.results != null) {
      for (var o in apiResponse.results) {
        final pawn = o as ParseObject;
        pawn.set("Position", 0);

        await pawn.save();
      }
    }
  }

  Future<void> endTurn(String session) async {

    final QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject(gameCollection))
          ..whereEqualTo("Session", session);

    final ParseResponse gameResponse = await query.query();

    for(var game in(gameResponse.result as List<ParseObject>) ){
      game.set("Done", true);

      await game.save();
    }
  }

  Future<String> joinPlayer(String session) async {
    var player = ParseObject(playerCollection)
      ..set('Name', 'Player Name')
      ..set('Session', session);

    await player.save();

    print("Player joined: ${player.objectId}");

    return player.objectId;
  }

  Future<Pawn> joinPawn(
      int position,
      int number,
      String session,
      String playerId) async {
    var pawn = ParseObject(pawnCollection)
      ..set('Position', position)
      ..set('X', 0)
      ..set('Y', 0)
      ..set('Number', number)
      ..set('Session', session)
      ..set('PlayerId', playerId);

    await pawn.save();

    print("Pawn added: ${pawn.objectId}");

    var result = Pawn(
        position: position,
        id: pawn.objectId,
        number: number,
        ownerId: playerId,
        x: 0,
        y: 0);

    return result;
  }

  Pawn toPawn(ParseObject pawn){

    var position = pawn.get("Position");
    var number = pawn.get("Number");
    var playerId = pawn.get("PlayerId");
    var x = pawn.get("X");
    var y = pawn.get("Y");

    var result = Pawn(
        position: position,
        id: pawn.objectId,
        number: number,
        ownerId: playerId,
        x: x,
        y: y);

    return result;
  }

  Future<void> movePawn(Pawn pawn, int amount) async {

    var apiResponse = await ParseObject(pawnCollection).getObject(pawn.id);

    if (apiResponse.success && apiResponse.results != null) {
      for (var o in apiResponse.results) {
        final parsePawn = o as ParseObject;
        parsePawn.set("Position", pawn.position + amount);

        await parsePawn.save();
      }
    }
  }

  void nextPlayer(PlayerService playerService) async {

    final QueryBuilder<ParseObject> query =
    QueryBuilder<ParseObject>(ParseObject(gameCollection))
      ..whereEqualTo("Session", playerService.session);

    final ParseResponse gameRasponce = await query.query();

    var game = (gameRasponce.result as List<ParseObject>).first;
    var playerId = game.get("PlayerId");

    var index = playerService.playerIds.indexOf(playerId);

    playerId =
    playerService.playerIds[(index + 1) % playerService.playerIds.length];

    game.set("PlayerId", playerId);
    game.set("Done", false);

    game.save();
  }
}
