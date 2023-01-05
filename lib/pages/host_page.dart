import 'package:flutter/material.dart';
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
  const HostPage({Key? key, required this.session, required this.host}) : super(key: key);

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

    return Scaffold(
      appBar: AppBar(
        title: Text("HostPage"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ...playerService.playerIds.map((e) => Text("Player: $e", style: TextStyle(color: playerService.currentPLayer == e? Colors.red: Colors.black),)),
            ElevatedButton(onPressed: () async {
              gameController.nextPlayer(playerService);

            }, child: Text("Start")),
            TextField(controller: _controller),
            // ElevatedButton(onPressed: () => launch(url, forceWebView: true), child: Text("Open player")),
            Row(children: [Board(), _buildQRCode()]),
          ],
        ),
      ),
    );
  }



  QrImage _buildQRCode() {
    return QrImage(
      data: url,
      version: QrVersions.auto,
      size: 100.0,
    );
  }
}
