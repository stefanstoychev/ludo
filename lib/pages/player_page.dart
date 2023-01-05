import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:provider/provider.dart';

import '../collections.dart';
import '../player_data.dart';
import '../provider/player_service.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key, required this.playerData}) : super(key: key);

  final PlayerData playerData;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  var _rolledValue = 0;

  @override
  Widget build(BuildContext context) {

    var service = Provider.of<PlayerService>(context);

    var isMyTurn = service.currentPLayer == widget.playerData.playerId;

    var isDiceRolled = _rolledValue > 0;

    var gameInProgress = service.gameId != null;

    var canMove = gameInProgress && isMyTurn && isDiceRolled;

    var canRowDice = isMyTurn && !isDiceRolled;

    var pawnToAvailableMoveAmount = <ParseObject, int>{};

    for (var pawn in widget.playerData.pawns) {
      pawnToAvailableMoveAmount[pawn] = _canMovePawn(pawn);
    }

    var canPass = gameInProgress &&
        isMyTurn &&
        isDiceRolled &&
        !pawnToAvailableMoveAmount.values.any((element) => element > 0);

    return Scaffold(
      appBar: AppBar(
        title: Text("Player page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(widget.playerData.playerId),
            ...buildPawnWidgetsList(canMove, pawnToAvailableMoveAmount, service),
            canPass ? _buildPassButton() : Container(),
            _buildRowDiceButton(canRowDice)
          ],
        ),
      ),
    );
  }

  List<Row> buildPawnWidgetsList(bool canMove,
      Map<ParseObject, int> pawnToAvailableMoveAmount, PlayerService service) {
    return widget.playerData.pawns
        .map((pawn) => Row(
          children: [
            Text("Position: ${pawn.get("Position")}"),
            ElevatedButton(
                onPressed: canMove && (pawnToAvailableMoveAmount[pawn])! > 0
                    ? () async {
                        _movePawn(
                                service, pawn, pawnToAvailableMoveAmount[pawn] ?? 0)
                            .then((value) => _endTurn(service.session));
                      }
                    : null,
                child: Text("Move ${pawn.objectId} $_rolledValue")),
          ],
        ))
        .toList();
  }

  ElevatedButton _buildPassButton() {
    return ElevatedButton(
        onPressed: () => _endTurn(widget.playerData.session),
        child: Text("Pass"));
  }

  Widget _buildRowDiceButton(bool canRowDice) {
    return Row(
      children: [
        ...List.generate(6, (index) =>
            ElevatedButton(
                onPressed: canRowDice
                    ? () {
                  _rolledValue = index + 1;

                  setState(() {});
                }
                    : null,
                child: Text("Row ${index + 1}")),),
        ElevatedButton(
            onPressed: canRowDice
                ? () {
                    var random = Random();

                    _rolledValue = random.nextInt(6) + 1;

                    setState(() {});
                  }
                : null,
            child: Text("Row Dice")),
      ],
    );
  }

  int _canMovePawn(ParseObject pawn) {
    var position = pawn.get<int>("Position");

    if (position == 0) {
      if (_rolledValue == 6) {
        return 1;
      } else {
        return 0;
      }
    }

    if (position + _rolledValue > 64) {
      return 0;
    }

    return _rolledValue;
  }

  Future<void> _movePawn(
      PlayerService service, ParseObject pawn, int amount) async {
    var position = pawn.get("Position");

    pawn.set("Position", position + amount);

    await pawn.save();
  }

  Future<void> _endTurn(String session) async {
    _rolledValue = 0;

    final QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject(gameCollection))
          ..whereEqualTo("Session", session);

    final ParseResponse gameResponse = await query.query();

    var game = (gameResponse.result as List<ParseObject>).first;

    game.set("Done", true);

    game.save();
  }
}