abstract class SmsProvider {
  Future<void> sendOtp({required String phone, required String code});
}

abstract class PaymentGatewayProvider {
  Future<String> createPayment({
    required int amount,
    required String description,
    required String callbackUrl,
  });

  Future<bool> verifyPayment({required String reference, required int amount});
}

abstract class MapProvider {
  String directionsUrl({required double latitude, required double longitude});
}

abstract class ObjectStorageProvider {
  Future<String> upload({required String key, required List<int> bytes});
  Future<void> delete(String key);
}

abstract class PushProvider {
  Future<void> send({
    required String target,
    required String title,
    required String body,
  });
}

/// Production can bind these contracts to Iranian or international providers
/// without changing Patogh domain logic.
class ProviderRegistry {
  final SmsProvider? sms;
  final PaymentGatewayProvider? payment;
  final MapProvider? maps;
  final ObjectStorageProvider? storage;
  final PushProvider? push;

  const ProviderRegistry({
    this.sms,
    this.payment,
    this.maps,
    this.storage,
    this.push,
  });
}
