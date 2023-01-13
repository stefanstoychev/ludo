import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:parse_test/game_controller.dart';
import 'package:parse_test/pages/player_page.dart';
import 'package:parse_test/player_data.dart';
import 'package:parse_test/settings.dart';
import 'package:provider/provider.dart';

import 'board_data.dart';
import 'host_data.dart';
import 'pages/host_page.dart';
import 'provider/player_service.dart';

Future<void> main() async {
  usePathUrlStrategy();

  await initializeParse();

  GameController gameController = GameController();

  var boardData = BoardData();

  Widget child;

  var isHost = isHostCheck();

  String session = Guid.newGuid.value ?? "";

  if(!isHost){
    session = getSessionFromUrlParams();
  }

  final service = PlayerService(session: session, board: boardData);

  if (!isHost) {
    var playerData = PlayerData(session: session);

    await playerData.initLiveQuery(service);

    await playerData.joinPlayer();

    child = PlayerPage(playerData: playerData);
  } else {
    var hostData = HostData(session: session);

    await hostData.initLiveQuery(gameController, service);

    await hostData.startGame();

    child = HostPage(
      session: session,
      host: hostData,
      url: getJoinUrl(session),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => service,
        ),
        ChangeNotifierProvider(
          create: (_) => gameController,
        ),
        ChangeNotifierProvider(
          create: (_) => boardData,
        ),
      ],
      child: MyApp(
        child: child,
      ),
    ),
  );
}

bool isHostCheck() {
  var createdSession = Uri.base.queryParameters["session"];

  var isHost = createdSession == null;

  return isHost;
}

String getSessionFromUrlParams() {
  var createdSession = Uri.base.queryParameters["session"];

  return createdSession!;
}

String getJoinUrl(String session){

  var joinUrl = "${Uri.base}?session=$session";

  return joinUrl;
}

Future<Parse> initializeParse() {
  Settings settings = kDebugMode ? LocalSettings() : ProdSettings();

  return Parse().initialize(
    settings.keyApplicationId,
    settings.keyParseServerUrl,
    liveQueryUrl: settings.keyLivequeryUrl,
    clientKey: settings.clientKey,
    debug: true,
    autoSendSessionId: true,
  );
}

class MyApp extends StatelessWidget {
  final Widget child;

  const MyApp({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: child,
    );
  }
}
