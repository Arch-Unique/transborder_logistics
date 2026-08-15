/// Browser-only capabilities, resolved per compile target.
///
/// `dart:js_interop` and `package:web` exist only on web (both dart2js and
/// dart2wasm). Importing them unconditionally breaks the Android and iOS
/// builds with:
///   FileSystemException(uri=org-dartlang-untranslatable-uri:dart%3Ajs_interop)
///
/// The `dart.library.js_interop` condition is true for dart2js *and* dart2wasm,
/// so it is the right test for "is this a browser". `dart.library.html` would
/// be wrong — it is false under dart2wasm and would send the wasm build to the
/// stub.
export 'browser_stub.dart' if (dart.library.js_interop) 'browser_web.dart';
