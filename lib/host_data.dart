import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';


import 'collections.dart';
import 'game_controller.dart';
import 'provider/player_service.dart';

class HostData {

  var session = "";

  var gameId = "";

  HostData({required this.session});

  Future<void> initLiveQuery(GameController gameController, PlayerService service) async {

    final LiveQuery liveQuery = LiveQuery();

    var playerQuery = QueryBuilder<ParseObject>(ParseObject(playerCollection))
      ..whereEqualTo('Session', session);

    Subscription playerSubscription = await liveQuery.client.subscribe(playerQuery);

    playerSubscription.on(LiveQueryEvent.create, (value) {
      print(" #### Game created event called");
      var objectId = (value as ParseObject).objectId;

      service.addPlayer(objectId);
    });

    var pawnQuery = QueryBuilder<ParseObject>(ParseObject(pawnCollection))
      ..whereEqualTo('Session', session);

    Subscription pawnSubscription = await liveQuery.client.subscribe(pawnQuery);

    pawnSubscription.on(LiveQueryEvent.create, (value) {
      print(" #### Player has joined event called");
      var objectId = (value as ParseObject).objectId;
      var ownerId = (value as ParseObject).get("PlayerId");
      var number = (value as ParseObject).get<int>("Number");

      service.addPawn(objectId, ownerId, number);
    });

    pawnSubscription.on(LiveQueryEvent.update, (value) {
      print(" #### Pawn moved");
      var pawn = value as ParseObject;

      var objectId = pawn.objectId;
      var position = pawn.get("Position");

      service.movePawn(objectId, position);
    });

    var gameQuery = QueryBuilder<ParseObject>(ParseObject(gameCollection))
      ..whereEqualTo('Session', session);

    Subscription gameSubscription = await liveQuery.client.subscribe(gameQuery);

    gameSubscription.on(LiveQueryEvent.update, (value) {

      print("### Player moved");

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