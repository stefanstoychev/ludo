import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/pawn.dart';
import 'model/tile.dart';
import 'provider/player_service.dart';
import 'utils/rotator.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

class Board extends StatelessWidget {
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

  static Tile SU =
      Tile(icon: CupertinoIcons.arrow_down_circle, color: Colors.blue);
  static Tile SD =
      Tile(icon: CupertinoIcons.arrow_up_circle, color: Colors.red);
  static Tile SR =
      Tile(icon: CupertinoIcons.arrow_left_circle, color: Colors.green);
  static Tile SL =
      Tile(icon: CupertinoIcons.arrow_right_circle, color: Colors.yellow);

  static Tile FU = Tile(icon: Icons.home, color: Colors.blue);
  static Tile FD = Tile(icon: Icons.home, color: Colors.red);
  static Tile FR = Tile(icon: Icons.home, color: Colors.green);
  static Tile FL = Tile(icon: Icons.home, color: Colors.yellow);

  static Tile PU =
      Tile(icon: CupertinoIcons.arrow_turn_right_down, color: Colors.blue);
  static Tile PD =
      Tile(icon: CupertinoIcons.arrow_turn_left_up, color: Colors.red);
  static Tile PR =
      Tile(icon: CupertinoIcons.arrow_turn_down_left, color: Colors.green);
  static Tile PL =
      Tile(icon: CupertinoIcons.arrow_turn_up_right, color: Colors.yellow);

  static Tile EA = Tile(
      icon: Icons.add_circle,
      color: Colors.white,
      hasBorder: false,
      isEmpty: true);
  static Tile PA =
      Tile(icon: Icons.accessibility, color: Colors.grey, isEmpty: true);

  final _board = [
    [EA, EA, EA, EA, EA, EA, PA, PU, SU, EA, EA, EA, EA, EA, EA],
    [EA, PA, EA, EA, EA, EA, PA, FU, PA, EA, EA, EA, EA, PA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FU, PA, EA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FU, PA, EA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FU, PA, EA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, PA, PA, FU, PA, PA, EA, EA, EA, EA, EA],
    [SL, PA, PA, PA, PA, PA, EA, FU, EA, PA, PA, PA, PA, PA, PA],
    [PL, FL, FL, FL, FL, FL, FL, EA, FR, FR, FR, FR, FR, FR, PR],
    [PA, PA, PA, PA, PA, PA, EA, FD, EA, PA, PA, PA, PA, PA, SR],
    [EA, EA, EA, EA, EA, PA, PA, FD, PA, PA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FD, PA, EA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FD, PA, EA, EA, EA, EA, EA, EA],
    [EA, EA, EA, EA, EA, EA, PA, FD, PA, EA, EA, EA, EA, EA, EA],
    [EA, PA, EA, EA, EA, EA, PA, FD, PA, EA, EA, EA, EA, PA, EA],
    [EA, EA, EA, EA, EA, EA, SD, PD, PA, EA, EA, EA, EA, EA, EA],
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

    var size = _board.length * _board.first.length;

    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: _board.length,
      // Generate 100 widgets that display their index in the List.
      children: List.generate(size, (index) {
        var colIndex = index ~/ _board.length;
        var rowIndex = index % _board.length;

        Tile tileCode = _board[colIndex][rowIndex];

        return _buildCell(playerService, tileCode, colIndex, rowIndex);
      }),
    );
  }

  Widget _buildCell(
      PlayerService playerService, Tile tile, int colIndex, int rowIndex) {
    List<Pawn> pawns = playerService.pawns.toList();

    var pawnsOnCell = pawns
        .where((element) => element.x == colIndex && element.y == rowIndex);

    Color color = Colors.grey.shade400;

    String text = "";

    Widget child;
    if (pawnsOnCell.isNotEmpty) {
      color =
          colors[playerService.playerIds.indexOf(pawnsOnCell.first.ownerId)];
      text = "${pawnsOnCell.length}";
      child = Text(text);
      child = GridView.count(crossAxisCount: 2,children: pawnsOnCell.map((e) => FittedBox(child:Text("${e.number}"))).toList(),);
    } else {
      if (tile.isEmpty) {
        child = const Text("");
      } else {
        child = Icon(tile.icon, color: tile.color);
      }
    }

    return Container(
        decoration: tile.hasBorder
            ? BoxDecoration(
                color: color,
                border: Border.all(width: 1, color: Colors.blueGrey))
            : null,
        child: child);
  }
}
