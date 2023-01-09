import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:parse_test/game_controller.dart';
import 'package:parse_test/pages/player_page.dart';
import 'package:parse_test/player_data.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'board.dart';
import 'collections.dart';
import 'host_data.dart';
import 'pages/host_page.dart';
import 'provider/player_service.dart';

String keyApplicationId = r"QrSbLXkrKHsybyjhJb1giMgF07HeGXFvVAjY9UCI";
String keyParseServerUrl = r"https://parseapi.back4app.com";
String clientKey = r"8tYgH0RfOknW8fMJ0d1NNGDhowVpndgGEXiBDTxW";

String keyLivequeryUrl = r"https://testappstefan.b4a.io";
String session = Guid.newGuid.value ?? "";

var url = Uri.base.toString();

Future<void> main() async {
  usePathUrlStrategy();

  var hasSessionParam = getSessionFromUrlParams();

  await initializeParse();

  PlayerService? service;
  GameController gameController = GameController();
  Widget child;

  var isHost = !hasSessionParam;

  if (!isHost) {
    var playerData = PlayerData(session: session);

    service = await playerData.initLiveQuery();
    await playerData.joinPlayer();

    child = PlayerPage(playerData: playerData);
  } else {
    var hostData = HostData(session: session);

    service = await hostData.initLiveQuery(gameController);

    await hostData.startGame();

    child = HostPage(
      session: session,
      host: hostData,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => service,),
        ChangeNotifierProvider(create: (_) => gameController,)
      ],
      child: MyApp(
        child: child,
      ),
    ),
  );
}

bool getSessionFromUrlParams() {
  var createdSession = Uri.base.queryParameters["session"];

  print("Session: $createdSession");

  if (createdSession != null) {
    session = createdSession;
    return true;
  } else {
    url += "?session=$session";

    return false;
  }
}

Future<void> initializeParse() async {
  var parse = await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    liveQueryUrl: keyLivequeryUrl,
    clientKey: clientKey,
    debug: true,
    autoSendSessionId: true,
  );
}

class MyApp extends StatelessWidget {
  final Widget child;

  const MyApp({Key? key, required this.child}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: child,
    );
  }
}
