import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'board_data.dart';
import 'model/pawn.dart';
import 'model/tile.dart';
import 'provider/player_service.dart';

class Board extends StatelessWidget {
  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];

  @override
  Widget build(BuildContext context) {
    var playerService = Provider.of<PlayerService>(context);
    var board = Provider.of<BoardData>(context);

    var size = board.height * board.width;

    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: board.width,
      // Generate 100 widgets that display their index in the List.
      children: List.generate(size, (index) {
        var colIndex = index ~/ board.height;
        var rowIndex = index % board.width;

        Tile tileCode = board.BOARD[colIndex][rowIndex];

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
      child = GridView.count(
        crossAxisCount: 2,
        children: pawnsOnCell
            .map((e) => FittedBox(child: Text("${e.number}")))
            .toList(),
      );
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
