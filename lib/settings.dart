abstract class Settings {
  String get keyApplicationId;
  String get keyParseServerUrl;
  String get clientKey;
  String get keyLivequeryUrl;
}

class LocalSettings implements Settings {
  @override
  String get keyApplicationId => r"myappID";
  @override
  String get keyParseServerUrl => r"http://localhost/parse";
  @override
  String get clientKey => r"188a6aa2-8c83-4412-beba-1e193a9b4bad";
  @override
  String get keyLivequeryUrl => r"http://localhost/parse";
}

class ProdSettings implements Settings {
  @override
  String get keyApplicationId => r"QrSbLXkrKHsybyjhJb1giMgF07HeGXFvVAjY9UCI";
  @override
  String get keyParseServerUrl => r"https://parseapi.back4app.com";
  @override
  String get clientKey => r"8tYgH0RfOknW8fMJ0d1NNGDhowVpndgGEXiBDTxW";
  @override
  String get keyLivequeryUrl => r"https://testappstefan.b4a.io";
}
