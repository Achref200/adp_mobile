/////
// secure_session_store.dart — Composition root for session persistence.
// Conditional import: web gets in-memory fallback; native gets flutter_secure_storage.
/////

import 'secure_session_store_stub.dart'
    if (dart.library.html) 'secure_session_store_web.dart'
    if (dart.library.io) 'secure_session_store_native.dart';

export 'secure_session_store_stub.dart'
    if (dart.library.html) 'secure_session_store_web.dart'
    if (dart.library.io) 'secure_session_store_native.dart';
// SecureSessionStore is declared in each platform file and re-exported here.
