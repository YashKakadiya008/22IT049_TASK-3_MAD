import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamController<bool> _connectionStatusController;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isOnline = false;

  ConnectivityService() {
    _connectionStatusController = StreamController<bool>.broadcast();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Initialize connectivity checking
  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      result = ConnectivityResult.none;
    }
    _updateConnectionStatus(result);
  }

  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    _isOnline = result != ConnectivityResult.none;
    _connectionStatusController.add(_isOnline);
  }

  // Get current online status
  bool get isOnline => _isOnline;

  // Stream of connection status changes
  Stream<bool> get onConnectionChange => _connectionStatusController.stream;

  // Manually check current connectivity
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return _isOnline;
  }

  // Dispose the service
  void dispose() {
    _connectivitySubscription.cancel();
    _connectionStatusController.close();
  }
} 