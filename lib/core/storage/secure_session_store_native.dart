/////
// secure_session_store_native.dart — Native mobile implementation.
// Loaded when dart.library.io is available (iOS / Android builds).
// Uses flutter_secure_storage with platform-native secure enclaves.
/////

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:adp_mobile/core/storage/secure_session_store_stub.dart';

/// Native platform storage backed by iOS Keychain and Android Keystore.
///
/// Tokens never leave the device's secure enclave in plain text.
class SecureSessionStore extends SecureSessionStoreStub {
  final FlutterSecureStorage _storage;

  SecureSessionStore()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: const IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);
}
