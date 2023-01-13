import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'collections.dart';
import 'provider/player_service.dart';

class GameController extends ChangeNotifier {
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
