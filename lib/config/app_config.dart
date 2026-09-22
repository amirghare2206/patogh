import 'package:firebase_core/firebase_core.dart';

class AppConfig {
  static const _productBuild = bool.fromEnvironment('dart.vm.product');
  static const mode = String.fromEnvironment(
    'PATOGH_MODE',
    defaultValue: _productBuild ? 'production' : 'demo',
  );
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const paymentApiBaseUrl = String.fromEnvironment(
    'PAYMENT_API_BASE_URL',
  );
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
  );
  static const firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const fcmVapidKey = String.fromEnvironment('FCM_VAPID_KEY');

  static bool get isDemo => mode == 'demo';
  static bool get isStaging => mode == 'staging';
  static bool get isProduction => mode == 'production';
  static bool get useSupabase =>
      (isStaging || isProduction) &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
  static bool get useStagingAnonymousAuth => isStaging && useSupabase;
  static bool get usePaymentApi => isProduction && paymentApiBaseUrl.isNotEmpty;
  static bool get useFirebase =>
      (isStaging || isProduction) &&
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;

  static FirebaseOptions get firebaseOptions => FirebaseOptions(
    apiKey: firebaseApiKey,
    appId: firebaseAppId,
    messagingSenderId: firebaseMessagingSenderId,
    projectId: firebaseProjectId,
    authDomain: firebaseAuthDomain.isEmpty ? null : firebaseAuthDomain,
    storageBucket: firebaseStorageBucket.isEmpty ? null : firebaseStorageBucket,
  );
}
