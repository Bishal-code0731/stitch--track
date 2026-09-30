import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `true` if any active network transport is present.
bool isOnline(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// Wraps `connectivity_plus` behind an interface.
class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// One-shot current status.
  Future<bool> currentStatus() async =>
      isOnline(await _connectivity.checkConnectivity());

  /// Online/offline, seeded with the current value then following changes.
  Stream<bool> watch() async* {
    yield await currentStatus();
    yield* _connectivity.onConnectivityChanged.map(isOnline);
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

/// App-facing online/offline status.
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).watch();
});
