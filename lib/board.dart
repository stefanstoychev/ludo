import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/pawn.dart';
import 'provider/player_service.dart';
import 'utils/rotator.dart';

class Board extends StatelessWidget {

  final double size = 40;

  final _playerPath = [
    [13, 1],
    ...List.generate(6, (index) => [9 + index, 6]).reversed,
    [8, 6],
    ...List.generate(6, (index) => [8, index]).reversed,
    [7, 0],
    ...List.generate(6, (index) => [6, index]),
    [6, 6],
    ...List.generate(6, (index) => [index, 6]).reversed,
    [0, 7],
    ...List.generate(6, (index) => [index, 8]),
    [6, 8],
    ...List.generate(6, (index) => [6, 9 + index]),
    [7, 14],
    ...List.generate(6, (index) => [8, 9 + index]).reversed,
    [8, 8],
    ...List.generate(6, (index) => [9 + index, 8]),
    ...List.generate(7, (index) => [8 + index, 7]).reversed,
  ];

  List<List<List<int>>> playerPaths = [];

  final _board = [
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
  ];

  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];

  Board() {
    var rotator = Rotator();

    var current = _playerPath;

    playerPaths.add(current);

    for (int i = 0; i < 3; i++) {
      current = rotator.rotate(current);
      // playerPaths.add(current);
      playerPaths.add(_playerPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    var playerService = Provider.of<PlayerService>(context);

    return Column(
      children: [
        Column(
          children: List.generate(_board.length, (colIndex) {
            var col = _board[colIndex];

            return Row(
              children: List.generate(col.length, (rowIndex) {
                var row = col[rowIndex];

                var tileCode = row;

                return _buildCell(playerService, tileCode, colIndex, rowIndex);
              }),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCell(
      PlayerService playerService, int tileCode, int colIndex, int rowIndex) {
    List<Pawn> pawns = playerService.pawns.toList();

    var pawnsOnCell = pawns
        .where((element) => element.x == colIndex && element.y == rowIndex);

    Color color = Colors.blueGrey;

    String text = "";

    if (pawnsOnCell.isNotEmpty) {
      color = colors[playerService.playerIds.indexOf(pawnsOnCell.first.ownerId)];
      text = "${pawnsOnCell.length}";
    } else {
      color = tileCode == 1 ? Colors.grey : Colors.white70;
    }

    return Container(
      height: size,
      width: size,
      child: Text(text),
      decoration: tileCode == 1
          ? BoxDecoration(
              color: color, border: Border.all(width: 2, color: Colors.black))
          : null,
    );
  }
}
