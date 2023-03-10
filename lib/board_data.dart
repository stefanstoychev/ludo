import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model/tile.dart';
import 'utils/rotator.dart';

class BoardData extends ChangeNotifier {
  static final _playerPath = [
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

  static Tile SU = const Tile(CupertinoIcons.arrow_down_circle, Colors.blue);
  static Tile SD = const Tile(CupertinoIcons.arrow_up_circle, Colors.red);
  static Tile SR = const Tile(CupertinoIcons.arrow_left_circle, Colors.green);
  static Tile SL = const Tile(CupertinoIcons.arrow_right_circle, Colors.yellow);

  static Tile FU = const Tile(Icons.home, Colors.blue);
  static Tile FD = const Tile(Icons.home, Colors.red);
  static Tile FR = const Tile(Icons.home, Colors.green);
  static Tile FL = const Tile(Icons.home, Colors.yellow);

  static Tile PU =
      const Tile(CupertinoIcons.arrow_turn_right_down, Colors.blue);
  static Tile PD = const Tile(CupertinoIcons.arrow_turn_left_up, Colors.red);
  static Tile PR =
      const Tile(CupertinoIcons.arrow_turn_down_left, Colors.green);
  static Tile PL =
      const Tile(CupertinoIcons.arrow_turn_up_right, Colors.yellow);

  static Tile EA = const Tile(Icons.add_circle, Colors.white,
      hasBorder: false, isEmpty: true);
  static Tile PA = const Tile(Icons.accessibility, Colors.grey, isEmpty: true);

  final BOARD = [
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

  int get height => BOARD.length;

  int get width => BOARD.first.length;

  int get maxPlayerIndex => _playerPath.length - 1;

  BoardData() {
    var rotator = Rotator();

    var current = _playerPath;

    playerPaths.add(current);

    for (int i = 0; i < 3; i++) {
      current = rotator.rotate(current);
      playerPaths.add(current);
    }
  }
}
