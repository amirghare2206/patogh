import 'package:flutter/foundation.dart';

enum StartupStatus {
  starting,
  ready,
  failed,
}

class StartupState extends ChangeNotifier {
  StartupStatus status = StartupStatus.starting;
  String stage = 'در حال راه‌اندازی پاتوق...';
  String? errorTitle;
  String? errorMessage;
  String? technicalDetails;
  bool canRetry = false;

  bool get isReady => status == StartupStatus.ready;
  bool get isFailed => status == StartupStatus.failed;

  void start() {
    status = StartupStatus.starting;
    stage = 'در حال راه‌اندازی پاتوق...';
    errorTitle = null;
    errorMessage = null;
    technicalDetails = null;
    canRetry = false;
    notifyListeners();
  }

  void setStage(String value) {
    status = StartupStatus.starting;
    stage = value;
    notifyListeners();
  }

  void ready() {
    status = StartupStatus.ready;
    stage = 'آماده شد';
    errorTitle = null;
    errorMessage = null;
    technicalDetails = null;
    canRetry = false;
    notifyListeners();
  }

  void fail({
    required String title,
    required String message,
    String? technicalDetails,
    bool canRetry = true,
  }) {
    status = StartupStatus.failed;
    errorTitle = title;
    errorMessage = message;
    this.technicalDetails = technicalDetails;
    this.canRetry = canRetry;
    notifyListeners();
  }
}

final StartupState startupState = StartupState();
