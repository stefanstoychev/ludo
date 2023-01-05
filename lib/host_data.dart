import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:parse_test/game_controller.dart';
import 'package:parse_test/provider/player_service.dart';

import 'collections.dart';

class HostData {

  var session = "";

  var gameId = "";

  HostData({required this.session});

  Future<PlayerService> initLiveQuery(GameController gameController) async {
    final LiveQuery liveQuery = LiveQuery();

    var service = PlayerService(session: session);

    var playerQuery = QueryBuilder<ParseObject>(ParseObject(playerCollection))
      ..whereEqualTo('Session', session);

    Subscription playerSubscription = await liveQuery.client.subscribe(playerQuery);

    playerSubscription.on(LiveQueryEvent.create, (value) {
      var objectId = (value as ParseObject).objectId;

      service.addPlayer(objectId);
    });

    var pawnQuery = QueryBuilder<ParseObject>(ParseObject(pawnCollection))
      ..whereEqualTo('Session', session);

    Subscription pawnSubscription = await liveQuery.client.subscribe(pawnQuery);

    pawnSubscription.on(LiveQueryEvent.create, (value) {
      var objectId = (value as ParseObject).objectId;
      var ownerId = (value as ParseObject).get("PlayerId");

      service.addPawn(objectId, ownerId);
    });

    pawnSubscription.on(LiveQueryEvent.update, (value) {
      var pawn = value as ParseObject;

      var objectId = pawn.objectId;
      var position = pawn.get("Position");

      service.movePawn(objectId, position);
    });

    var gameQuery = QueryBuilder<ParseObject>(ParseObject(gameCollection))
      ..whereEqualTo('Session', session);

    Subscription gameSubscription = await liveQuery.client.subscribe(gameQuery);

    gameSubscription.on(LiveQueryEvent.update, (value) {

      print(value);

      var game = value as ParseObject;

      var objectId = game.objectId;
      var playerId = game.get("PlayerId");
      var done = game.get<bool>("Done");

      service.setGameId(objectId);
      service.currentPlayer(playerId);

      if(!done)
        return;

      gameController.nextPlayer(service);
    });

    return service;
  }

  Future<void> startGame() async {

    var game = ParseObject(gameCollection)
      ..set('Session', session)
      ..set('Done', false)
      ..set('PlayerId', "");

    await game.save();

    gameId = game.objectId;
  }
}