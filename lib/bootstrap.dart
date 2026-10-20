import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/state/startup_state.dart';

bool _bootstrapRunning = false;

Future<void> bootstrapPatogh() async {
  if (_bootstrapRunning) return;
  _bootstrapRunning = true;

  startupState.start();

  try {
    startupState.setStage('دارم سرویس‌های پاتوق را آماده می‌کنم...');
    await PlatformServices.initialize().timeout(
      const Duration(seconds: 20),
    );

    startupState.setStage('دارم اطلاعات اولیه پاتوق را بارگذاری می‌کنم...');
    await appState.init().timeout(
      const Duration(seconds: 60),
    );

    startupState.ready();
  } on TimeoutException catch (error, stackTrace) {
    debugPrint('PATOGH_STARTUP_TIMEOUT: $error');
    debugPrintStack(stackTrace: stackTrace);

    startupState.fail(
      title: 'راه‌اندازی بیشتر از حد معمول طول کشید',
      message:
          'پاتوق در مرحله «${startupState.stage}» منتظر پاسخ ماند و پاسخ به‌موقع نرسید. '
          'احتمالاً اتصال اینترنت یا یکی از سرویس‌های تست در دسترس نیست.',
      technicalDetails: _safeDetails(error),
      canRetry: false,
    );
  } catch (error, stackTrace) {
    debugPrint('PATOGH_STARTUP_ERROR: $error');
    debugPrintStack(stackTrace: stackTrace);

    startupState.fail(
      title: _humanizeStartupError(error),
      message:
          'راه‌اندازی پاتوق در مرحله «${startupState.stage}» متوقف شد. '
          'جزئیات فنی را می‌توانی کپی کنی تا علت را دقیق بررسی کنیم.',
      technicalDetails: _safeDetails(error),
      canRetry: true,
    );
  } finally {
    _bootstrapRunning = false;
  }
}

String _humanizeStartupError(Object error) {
  final raw = error.toString();

  if (raw.contains('SocketException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('Connection reset') ||
      raw.contains('Network is unreachable')) {
    return 'اتصال اینترنت یا دسترسی به سرور برقرار نشد';
  }

  if (raw.contains('PostgrestException') ||
      raw.contains('PGRST') ||
      raw.contains('PostgREST')) {
    return 'سرور اطلاعات پاتوق پاسخ مورد انتظار را نداد';
  }

  if (raw.contains('AuthException') ||
      raw.contains('authentication') ||
      raw.contains('AUTH_BACKEND_NOT_CONFIGURED')) {
    return 'اتصال بخش ورود و حساب کاربری کامل نیست';
  }

  if (raw.contains('Firebase')) {
    return 'راه‌اندازی سرویس اعلان‌ها (Firebase) با مشکل روبه‌رو شد';
  }

  return 'راه‌اندازی پاتوق با یک خطای غیرمنتظره متوقف شد';
}

String _safeDetails(Object error) {
  var raw = error.toString();

  raw = raw.replaceAll(
    RegExp(r'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+'),
    '[کلید حذف شد]',
  );
  raw = raw.replaceAll(
    RegExp(r'https?://[^\s]+'),
    '[آدرس سرویس حذف شد]',
  );

  if (raw.length > 2400) {
    raw = '${raw.substring(0, 2400)}\n...';
  }

  return '${error.runtimeType}: $raw';
}
