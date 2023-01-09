import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:parse_test/game_controller.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../board.dart';
import '../collections.dart';
import '../host_data.dart';
import '../main.dart';
import '../provider/player_service.dart';

class HostPage extends StatefulWidget {
  final HostData host;

  const HostPage({Key? key, required this.session, required this.host})
      : super(key: key);

  final String session;

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  final TextEditingController _controller = TextEditingController(text: url);

  @override
  Widget build(BuildContext context) {
    var playerService = Provider.of<PlayerService>(context);
    var gameController = Provider.of<GameController>(context);

    var size = MediaQuery.of(context).size;

    var boardSize = min(size.height, size.width);

    var board = Board();

    var qrCode = _buildQRCode();

    var players = playerService.playerIds.map((e) => Text(
          "Player: $e",
          style: TextStyle(
              color:
                  playerService.currentPLayer == e ? Colors.red : Colors.black),
        ));

    var startButton = ElevatedButton(
        onPressed: () async {
          gameController.nextPlayer(playerService);
        },
        child: Text("Start"));

    return Scaffold(
      body: Row(
        children: [
          Container(
            height: boardSize,
            width: boardSize,
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.blueGrey)),
            child: board,
          ),
          Column(
            children: [
              ...players,
              qrCode,
              startButton,
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    return ElevatedButton(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: url));
        },
        child: QrImage(
          data: url,
          version: QrVersions.auto,
          size: 100.0,
        ));
  }
}
