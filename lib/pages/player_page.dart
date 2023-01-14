import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../board_data.dart';
import '../model/pawn.dart';
import '../player_data.dart';
import '../provider/parse_server.dart';
import '../provider/player_service.dart';

class PlayerPage extends StatefulWidget {

  const PlayerPage({Key? key, required this.playerData, required this.parseServer}) : super(key: key);

  final PlayerData playerData;

  final ParseServer parseServer;

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

    var pawnToAvailableMoveAmount = <Pawn, int>{};

    var boardData = Provider.of<BoardData>(context);

    for (var pawn in widget.playerData.pawns) {
      pawnToAvailableMoveAmount[pawn] = _canMovePawn(pawn, boardData.maxPlayerIndex);
    }

    var hasAvailableMoves = pawnToAvailableMoveAmount.values.any((element) => element > 0);

    var canPass = gameInProgress &&
        isMyTurn &&
        isDiceRolled &&
        !hasAvailableMoves;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Player page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(widget.playerData.playerId),
            _rolledValue > 0
                ? Text("Dice Roll: $_rolledValue",
                    style: const TextStyle(fontSize: 30))
                : Container(),
            canPass ? _buildPassButton() : Container(),
            Expanded(
              child: GridView.count(
                childAspectRatio: 2,
                crossAxisCount: 2,
                children: buildPawnWidgetsList(
                        canMove, pawnToAvailableMoveAmount, service)
                    .toList(),
              ),
            ),
            Row(
              children: [
                _buildRowDiceButton(canRowDice),
              ],
            )
          ],
        ),
      ),
    );
  }

  List<Widget> buildPawnWidgetsList(bool canMove,
      Map<Pawn, int> pawnToAvailableMoveAmount,
      PlayerService service) {
    return widget.playerData.pawns
        .map((pawn) => FittedBox(
          child: ElevatedButton(
                    onPressed: canMove && (pawnToAvailableMoveAmount[pawn])! > 0
                        ? () async {
                            await widget.parseServer.movePawn(pawn, pawnToAvailableMoveAmount[pawn] ?? 0);

                            await _endTurn(service.session);

                            print("Calling set state");
                            setState(() {});
                          }
                        : null,
                    child: Text("Move ${pawn.number}")),
        ),
            )
        .toList();
  }

  ElevatedButton _buildPassButton() {
    return ElevatedButton(
        onPressed: () => _endTurn(widget.playerData.session),
        child: const Text("Pass"));
  }

  Widget _buildRowDiceButton(bool canRowDice) {
    return Row(
      children: [
        ...kDebugMode?List.generate(
          6,
          (index) => ElevatedButton(
              onPressed: canRowDice
                  ? () {
                      _rolledValue = index + 1;

                      setState(() {});
                    }
                  : null,
              child: Text("Row ${index + 1}")),
        ):[],
        ElevatedButton(
            onPressed: canRowDice
                ? () {
                    setState(() {
                      var random = Random();

                      _rolledValue = random.nextInt(6) + 1;
                    });
                  }
                : null,
            child: Text("Row Dice")),
      ],
    );
  }

  int _canMovePawn(Pawn pawn, int maxPathIndex) {
    var position = pawn.position;

    if (position == 0) {
      if (_rolledValue == 6) {
        return 1;
      } else {
        return 0;
      }
    }

    if (position + _rolledValue > maxPathIndex) {
      return 0;
    }

    return _rolledValue;
  }

  Future<void> _endTurn(String session) async {
    _rolledValue = 0;

    if(_rolledValue == 6)
      return;

    await widget.parseServer.endTurn(session);
  }
}
