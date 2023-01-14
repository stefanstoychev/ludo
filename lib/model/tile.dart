import 'package:flutter/material.dart';

class Tile {
  final IconData icon;
  final Color color;
  final bool hasBorder;
  final bool isEmpty;

  const Tile({required this.icon, required this.color, this.hasBorder = true, this.isEmpty = false});
}
