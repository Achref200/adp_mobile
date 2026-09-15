/////
// secure_session_store.dart — Composition root for session persistence.
// Conditional export: web gets in-memory store; native gets flutter_secure_storage.
/////
library;

export 'secure_session_store_web.dart'
    if (dart.library.io) 'secure_session_store_native.dart';
// SecureSessionStore is declared in each platform file and re-exported here.
