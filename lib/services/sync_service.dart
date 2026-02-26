import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cashflow/services/auth_service.dart';
import 'package:cashflow/services/connectivity_service.dart';
import 'package:cashflow/services/cache_service.dart';
import 'package:cashflow/utils/app_urls.dart';

class SyncService {
  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;
  SyncService._();

  final ConnectivityService _connectivity = ConnectivityService();
  final OfflineCacheService _cache = OfflineCacheService();
  final AuthService _authService = AuthService();

  StreamSubscription<bool>? _subscription;
  Completer<void>? _syncCompleter;

  void startListening() {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((connected) {
      if (connected) {
        syncPendingOperations();
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> syncPendingOperations() async {
    if (_syncCompleter != null) {
      return _syncCompleter!.future;
    }
    _syncCompleter = Completer<void>();

    try {
      final isOnline = await _connectivity.checkConnectivity();
      if (!isOnline) return;

      final operations = await _cache.getPendingOperations();
      if (operations.isEmpty) return;

      String? token = await _authService.getToken();
      if (token == null) return;

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      for (final op in operations) {
        try {
          await _executeOperation(op, headers);
          await _cache.removePendingOperation(op.id);
        } catch (e) {
          break;
        }
      }
    } finally {
      _syncCompleter!.complete();
      _syncCompleter = null;
    }
  }

  Future<void> _executeOperation(
    PendingOperation op,
    Map<String, String> headers,
  ) async {
    late http.Response response;

    switch (op.type) {
      case 'create_book':
        response = await http.post(
          AppUrls.uri(AppUrls.createBook),
          headers: headers,
          body: jsonEncode({'name': op.data['name']}),
        );
        break;
      case 'update_book':
        response = await http.post(
          AppUrls.uri(AppUrls.updateBook),
          headers: headers,
          body: jsonEncode({
            'book_id': op.data['book_id'],
            'name': op.data['name'],
          }),
        );
        break;
      case 'delete_book':
        response = await http.post(
          AppUrls.uri(AppUrls.deleteBook),
          headers: headers,
          body: jsonEncode({'book_id': op.data['book_id']}),
        );
        break;
      case 'create_transaction':
        response = await http.post(
          AppUrls.uri(AppUrls.createTransaction),
          headers: headers,
          body: jsonEncode({
            'book_id': op.data['book_id'],
            'type': op.data['type'],
            'amount': op.data['amount'],
            'description': op.data['description'],
          }),
        );
        break;
      case 'update_transaction':
        response = await http.post(
          AppUrls.uri(AppUrls.updateTransaction),
          headers: headers,
          body: jsonEncode({
            'transaction_id': op.data['transaction_id'],
            'amount': op.data['amount'],
            'description': op.data['description'] ?? '',
          }),
        );
        break;
      case 'delete_transaction':
        response = await http.post(
          AppUrls.uri(AppUrls.deleteTransaction),
          headers: headers,
          body: jsonEncode({'transaction_id': op.data['transaction_id']}),
        );
        break;
      default:
        return;
    }

    if (response.statusCode != 200) {
      throw Exception('Sync failed: ${response.statusCode}');
    }
  }
}
