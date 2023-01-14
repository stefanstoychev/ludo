import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'collections.dart';
import 'model/pawn.dart';
import 'provider/parse_server.dart';
import 'provider/player_service.dart';

class PlayerData {
  var session = "";
  var playerId = "";

  var pawns = <Pawn>[];

  ParseServer parseServer;

  PlayerData({required this.session, required this.parseServer});

  Future<void> joinPlayer() async {
    playerId = await parseServer.joinPlayer(session);

    for (var i = 0; i < 4; i++) {
      var position = 0;
      var number = i + 1;

      var pawn =
          await parseServer.joinPawn(position, number, session, playerId);

      pawns.add(pawn);
    }
  }

  Future<void> initLiveQuery(PlayerService service) async {
    final LiveQuery liveQuery = LiveQuery();

    var pawnQuery = QueryBuilder<ParseObject>(ParseObject(pawnCollection))
      ..whereEqualTo('Session', session);

    Subscription pawnSubscription = await liveQuery.client.subscribe(pawnQuery);

    pawnSubscription.on(LiveQueryEvent.update, (value) {
      var pawn = value as ParseObject;

      var objectId = pawn.objectId;

      Pawn first = pawns.firstWhere((element) => element.id == objectId);

      var position = pawn.get("Position");
      var x = pawn.get("X");
      var y = pawn.get("Y");

      first.position = position;

      first.x = x;
      first.y = y;
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
  }
}
