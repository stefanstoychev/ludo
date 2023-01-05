import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:parse_test/provider/player_service.dart';

import 'collections.dart';


class PlayerData {

  var session = "";
  var playerId = "";

  var pawns = <ParseObject>[];

  PlayerData({required this.session});

  Future<void> joinPlayer() async {
    var player = ParseObject(playerCollection)
      ..set('Name', 'Player Name')
      ..set('Session', session);

    await player.save();

    playerId = player.objectId;

    print("Player joined: ${player.objectId}");

    for (var i = 0; i < 4; i++) {
      var pawn = ParseObject(pawnCollection)
        ..set('Position', 0)
        ..set('Session', session)
        ..set('PlayerId', playerId);

      await pawn.save();

      pawns.add(pawn);

      print("Pawn added: ${pawn.objectId}");
    }
  }

  Future<PlayerService> initLiveQuery() async {
    final LiveQuery liveQuery = LiveQuery();

    var service = PlayerService(session: session);

    var pawnQuery = QueryBuilder<ParseObject>(ParseObject(pawnCollection))
      ..whereEqualTo('Session', session);

    Subscription pawnSubscription = await liveQuery.client.subscribe(pawnQuery);

    pawnSubscription.on(LiveQueryEvent.update, (value) {
      var pawn = value as ParseObject;

      var objectId = pawn.objectId;
      var position = pawn.get("Position");

      pawns.firstWhere((element) => element.objectId == objectId).set("Position", position);
    });

    var gameQuery = QueryBuilder<ParseObject>(ParseObject(gameCollection))
      ..whereEqualTo('Session', session);

    Subscription gameSubscription = await liveQuery.client.subscribe(gameQuery);

    gameSubscription.on(LiveQueryEvent.update, (value) {
      var game = value as ParseObject;

      var playerId = game.get("PlayerId");
      var objectId = game.objectId;

      service.setGameId(objectId);
      service.currentPlayer(playerId);
    });

    return service;
  }
}