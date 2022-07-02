import 'package:flutter/cupertino.dart' show immutable;

typedef ClosingLoadingScreen = bool Function();
typedef UpdatingLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final ClosingLoadingScreen close;
  final UpdatingLoadingScreen update;

  LoadingScreenController({required this.close, required this.update});
}
