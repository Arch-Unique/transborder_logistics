import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

/// Detects that a newer build has been deployed while the app is open.
///
/// Every deploy rewrites `flutter_bootstrap.js`, so the web server hands back a
/// different `ETag` for it. Comparing that against the tag seen at startup tells
/// us the running bundle is stale — no build-time version coordination needed,
/// and it stays correct even if the pubspec version is not bumped.
///
/// Web only; on other platforms every method is a no-op.
class VersionService extends GetxService {
  VersionService({Duration? pollInterval})
    : pollInterval = pollInterval ?? const Duration(minutes: 5);

  /// How often to re-check. The request is a HEAD against a ~10KB file, so this
  /// is cheap enough to run for the lifetime of a session.
  final Duration pollInterval;

  /// Flips to true once the server reports a build different from ours.
  final RxBool hasUpdate = false.obs;

  final Dio _dio = Dio(BaseOptions(validateStatus: (_) => true));
  String? _startupTag;
  Timer? _timer;

  /// Resolved against the page URL, not the API host, so it works under any
  /// base href (the app is served from /app on tbl.ng).
  String get _target => Uri.base.resolve('flutter_bootstrap.js').toString();

  Future<VersionService> init() async {
    if (!kIsWeb) return this;
    _startupTag = await _fetchTag();
    if (_startupTag != null) {
      _timer = Timer.periodic(pollInterval, (_) => check());
    }
    return this;
  }

  /// Compares the deployed build against the one this session loaded.
  Future<void> check() async {
    if (!kIsWeb || hasUpdate.value || _startupTag == null) return;
    final tag = await _fetchTag();
    if (tag != null && tag != _startupTag) {
      hasUpdate.value = true;
      _timer?.cancel();
    }
  }

  /// ETag when the server sends one, falling back to Last-Modified — the deploy
  /// copies files fresh, so the timestamp moves even when content is identical.
  Future<String?> _fetchTag() async {
    try {
      final res = await _dio.head(
        _target,
        options: Options(headers: {'cache-control': 'no-cache'}),
      );
      if (res.statusCode == null || res.statusCode! >= 400) return null;
      return res.headers.value('etag') ?? res.headers.value('last-modified');
    } catch (_) {
      // Offline or the asset moved — try again on the next tick.
      return null;
    }
  }

  /// Hard-reloads onto the newly deployed build.
  void reload() {
    if (!kIsWeb) return;
    web.window.location.reload();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
