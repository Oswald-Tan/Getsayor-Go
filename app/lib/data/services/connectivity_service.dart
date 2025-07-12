import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Stream<bool> get connectivityStatus => _connectivityController.stream;
  final _connectivityController = StreamController<bool>.broadcast();

  void initialize() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        await _checkConnectivity(results);
      },
    );

    // Check initial status
    _connectivity.checkConnectivity().then(_checkConnectivity);
  }

  Future<void> _checkConnectivity(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none)) {
      _connectivityController.add(false);
    } else {
      final hasInternet = await _internetChecker.hasInternetAccess;
      _connectivityController.add(hasInternet);
    }
  }

  Future<bool> isConnectionSlow({int thresholdMs = 2000}) async {
    final stopwatch = Stopwatch()..start();
    final hasInternet = await _internetChecker.hasInternetAccess;
    stopwatch.stop();

    // Optional: untuk debugging
    print('Ping time: ${stopwatch.elapsedMilliseconds} ms');

    return !hasInternet || stopwatch.elapsedMilliseconds > thresholdMs;
  }

  Future<bool> checkConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;
    return await _internetChecker.hasInternetAccess;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
