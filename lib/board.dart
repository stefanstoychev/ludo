import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/pawn.dart';
import 'model/tile.dart';
import 'provider/player_service.dart';
import 'utils/rotator.dart';

class Board extends StatelessWidget {
  final double size = 30;

  final _playerPath = [
    [13, 1],
    ...List.generate(6, (index) => [9 + index, 6]).reversed,
    [9, 5],
    ...List.generate(6, (index) => [8, index]).reversed,
    [7, 0],
    ...List.generate(6, (index) => [6, index]),
    [5, 5],
    ...List.generate(6, (index) => [index, 6]).reversed,
    [0, 7],
    ...List.generate(6, (index) => [index, 8]),
    [5, 9],
    ...List.generate(6, (index) => [6, 9 + index]),
    [7, 14],
    ...List.generate(6, (index) => [8, 9 + index]).reversed,
    [9, 9],
    ...List.generate(6, (index) => [9 + index, 8]),
    ...List.generate(7, (index) => [8 + index, 7]).reversed,
  ];

  List<List<List<int>>> playerPaths = [];

  static Tile SU = Tile(icon: Icons.arrow_circle_down, color: Colors.blue);
  static Tile SD = Tile(icon: Icons.arrow_circle_up, color: Colors.red);
  static Tile SR =
      Tile(icon: Icons.arrow_circle_left_outlined, color: Colors.green);
  static Tile SL =
      Tile(icon: Icons.arrow_circle_right_outlined, color: Colors.yellow);

  static Tile FU = Tile(icon: Icons.home, color: Colors.blue);
  static Tile FD = Tile(icon: Icons.home, color: Colors.red);
  static Tile FR = Tile(icon: Icons.home, color: Colors.green);
  static Tile FL = Tile(icon: Icons.home, color: Colors.yellow);

  static Tile EA = Tile(
      icon: Icons.add_circle,
      color: Colors.white,
      hasBorder: false,
      isEmpty: true);
  static Tile PA =
      Tile(icon: Icons.accessibility, color: Colors.grey, isEmpty: true);

  final _board = [
    [EA, EA, EA, EA, EA, EA, PA, PA, SU, EA, EA, EA, EA, EA, EA],
    [EA, PA, EA, EA, EA, EA, PA, FU, PA, EA, EA, EA, EA, PA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FU, PA, EA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FU, PA, EA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FU, PA, EA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, PA, PA, FU, PA, PA, EA, EA, EA, EA, EA],
    [SL, PA, PA, PA, PA, PA, EA, FU, EA, PA, PA, PA, PA, PA, PA],
    [PA, FL, FL, FL, FL, FL, FL, EA, FR, FR, FR, FR, FR, FR, PA],
    [PA, PA, PA, PA, PA, PA, EA, FD, EA, PA, PA, PA, PA, PA, SR],
    [EA, EA, EA, EA, EA, PA, PA, FD, PA, PA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FD, PA, EA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FD, PA, EA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FD, PA, EA, EA, EA, EA, EA, EA],
    [EA, PA, EA, EA, EA, EA, PA, FD, PA, EA, EA, EA, EA, PA, EA],
    [EA, EA, EA, EA, EA, EA, SD, PA, PA, EA, EA, EA, EA, EA, EA],
  ];

  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];

  Board() {
    var rotator = Rotator();

    var current = _playerPath;

    playerPaths.add(current);

    for (int i = 0; i < 3; i++) {
      current = rotator.rotate(current);
      playerPaths.add(current);
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

                Tile tileCode = row;

                return _buildCell(playerService, tileCode, colIndex, rowIndex);
              }),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCell(
      PlayerService playerService, Tile tile, int colIndex, int rowIndex) {
    List<Pawn> pawns = playerService.pawns.toList();

    var pawnsOnCell = pawns
        .where((element) => element.x == colIndex && element.y == rowIndex);

    Color color = Colors.blueGrey;

    String text = "";

    if (pawnsOnCell.isNotEmpty) {
      color =
          colors[playerService.playerIds.indexOf(pawnsOnCell.first.ownerId)];
      text = "${pawnsOnCell.length}";
    } else {
      color = tile == 1 ? Colors.white70 : Colors.white;
    }

    Widget child = Text(text);

    if (!tile.isEmpty)
      child = Icon(tile.icon, color: tile.color);

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      child: child,
      decoration: tile.hasBorder
          ? BoxDecoration(
              color: Colors.grey,
              border: Border.all(width: 1, color: Colors.blueGrey))
          : null,
    );
  }
}
