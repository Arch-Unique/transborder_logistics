import 'dart:typed_data';

/// Non-web implementation. Every call site is behind `kIsWeb`, so reaching
/// [saveBytesInBrowser] here means a guard was dropped — fail loudly rather
/// than silently doing nothing.
String? saveBytesInBrowser(Uint8List bytes, String fileName) {
  throw UnsupportedError('saveBytesInBrowser is only available on the web');
}

/// No page to reload outside a browser; native builds simply do nothing.
void reloadPage() {}
