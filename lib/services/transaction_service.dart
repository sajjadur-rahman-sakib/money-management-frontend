import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money/services/auth_service.dart';
import 'package:money/services/connectivity_service.dart';
import 'package:money/services/cache_service.dart';
import 'package:money/services/sync_service.dart';
import 'package:money/utils/app_urls.dart';
import 'package:uuid/uuid.dart';

class TransactionService {
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivity = ConnectivityService();
  final OfflineCacheService _cache = OfflineCacheService();

  Future<Map<String, dynamic>> getBookDetails(String bookId) async {
    final isOnline = await _connectivity.checkConnectivity();

    if (isOnline) {
      try {
        await SyncService().syncPendingOperations();
      } catch (_) {}

      final hasPending = await _cache.hasPendingOperations();
      if (!hasPending) {
        try {
          String? token = await _authService.getToken();
          var response = await http.post(
            AppUrls.uri(AppUrls.bookDetails),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'book_id': bookId}),
          );
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            await _cache.cacheBookDetails(bookId, data);
            return data;
          }
        } catch (_) {}
      }
    }

    final cached = await _cache.getCachedBookDetails(bookId);
    if (cached != null) return cached;
    final cachedBooks = await _cache.getCachedBooks();
    Map<String, dynamic> fallbackBook = {
      'id': bookId,
      'name': 'Unknown',
      'balance': 0.0,
    };
    if (cachedBooks != null) {
      final match = cachedBooks.where((b) => b['id'] == bookId).toList();
      if (match.isNotEmpty) {
        fallbackBook = match.first;
      }
    }
    final fallback = {
      'book': fallbackBook,
      'transactions': [],
      'balance': (fallbackBook['balance'] as num?)?.toDouble() ?? 0.0,
    };
    await _cache.cacheBookDetails(bookId, fallback);
    return fallback;
  }

  Future<void> createTransaction(
    String bookId,
    String type,
    double amount,
    String? description,
  ) async {
    final isOnline = await _connectivity.checkConnectivity();

    if (isOnline) {
      try {
        String? token = await _authService.getToken();
        var response = await http.post(
          AppUrls.uri(AppUrls.createTransaction),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'book_id': bookId,
            'type': type,
            'amount': amount,
            'description': description,
          }),
        );
        if (response.statusCode == 200) return;
      } catch (_) {}
    }

    {
      final tempId = const Uuid().v4();
      await _cache.addPendingOperation(
        PendingOperation(
          id: tempId,
          type: 'create_transaction',
          data: {
            'book_id': bookId,
            'type': type,
            'amount': amount,
            'description': description,
          },
          createdAt: DateTime.now(),
        ),
      );

      var cached = await _cache.getCachedBookDetails(bookId);
      if (cached == null) {
        final cachedBooks = await _cache.getCachedBooks();
        Map<String, dynamic> fallbackBook = {
          'id': bookId,
          'name': 'Unknown',
          'balance': 0.0,
        };
        if (cachedBooks != null) {
          final match = cachedBooks.where((b) => b['id'] == bookId).toList();
          if (match.isNotEmpty) fallbackBook = match.first;
        }
        cached = {'book': fallbackBook, 'transactions': [], 'balance': 0.0};
      }

      final transactions = List<Map<String, dynamic>>.from(
        cached['transactions'] ?? [],
      );
      transactions.insert(0, {
        'id': tempId,
        'book_id': bookId,
        'type': type,
        'amount': amount,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      });
      cached['transactions'] = transactions;

      double balance = (cached['balance'] as num?)?.toDouble() ?? 0.0;
      if (type == 'cash_in') {
        balance += amount;
      } else {
        balance -= amount;
      }
      cached['balance'] = balance;
      if (cached['book'] is Map) {
        (cached['book'] as Map)['balance'] = balance;
      }

      await _cache.cacheBookDetails(bookId, cached);
    }
  }

  Future<void> updateTransaction(
    String transactionId,
    double amount,
    String description,
  ) async {
    final isOnline = await _connectivity.checkConnectivity();

    if (isOnline) {
      try {
        String? token = await _authService.getToken();
        var response = await http.post(
          AppUrls.uri(AppUrls.updateTransaction),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'transaction_id': transactionId,
            'amount': amount,
            'description': description,
          }),
        );
        if (response.statusCode == 200) return;
      } catch (_) {}
    }

    {
      await _cache.addPendingOperation(
        PendingOperation(
          id: const Uuid().v4(),
          type: 'update_transaction',
          data: {
            'transaction_id': transactionId,
            'amount': amount,
            'description': description,
          },
          createdAt: DateTime.now(),
        ),
      );

      final allBooks = await _cache.getCachedBooks();
      if (allBooks != null) {
        for (final book in allBooks) {
          final bookId = book['id'];
          final cached = await _cache.getCachedBookDetails(bookId);
          if (cached == null) continue;
          final transactions = List<Map<String, dynamic>>.from(
            cached['transactions'] ?? [],
          );
          final idx = transactions.indexWhere(
            (t) => t['id'].toString() == transactionId,
          );
          if (idx != -1) {
            final oldAmount = (transactions[idx]['amount'] as num).toDouble();
            final oldType = transactions[idx]['type'];
            transactions[idx]['amount'] = amount;
            transactions[idx]['description'] = description;
            cached['transactions'] = transactions;
            double bal = (cached['balance'] as num?)?.toDouble() ?? 0.0;
            if (oldType == 'cash_in') {
              bal -= oldAmount;
            } else {
              bal += oldAmount;
            }
            if (oldType == 'cash_in') {
              bal += amount;
            } else {
              bal -= amount;
            }
            cached['balance'] = bal;
            if (cached['book'] is Map) {
              (cached['book'] as Map)['balance'] = bal;
            }
            await _cache.cacheBookDetails(bookId, cached);
            break;
          }
        }
      }
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    final isOnline = await _connectivity.checkConnectivity();

    if (isOnline) {
      try {
        String? token = await _authService.getToken();
        var response = await http.post(
          AppUrls.uri(AppUrls.deleteTransaction),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'transaction_id': transactionId}),
        );
        if (response.statusCode == 200) return;
      } catch (_) {}
    }

    {
      await _cache.addPendingOperation(
        PendingOperation(
          id: const Uuid().v4(),
          type: 'delete_transaction',
          data: {'transaction_id': transactionId},
          createdAt: DateTime.now(),
        ),
      );

      final allBooks = await _cache.getCachedBooks();
      if (allBooks != null) {
        for (final book in allBooks) {
          final bookId = book['id'];
          final cached = await _cache.getCachedBookDetails(bookId);
          if (cached == null) continue;
          final transactions = List<Map<String, dynamic>>.from(
            cached['transactions'] ?? [],
          );
          final idx = transactions.indexWhere(
            (t) => t['id'].toString() == transactionId,
          );
          if (idx != -1) {
            final removedAmount = (transactions[idx]['amount'] as num)
                .toDouble();
            final removedType = transactions[idx]['type'];
            transactions.removeAt(idx);
            cached['transactions'] = transactions;
            double bal = (cached['balance'] as num?)?.toDouble() ?? 0.0;
            if (removedType == 'cash_in') {
              bal -= removedAmount;
            } else {
              bal += removedAmount;
            }
            cached['balance'] = bal;
            if (cached['book'] is Map) {
              (cached['book'] as Map)['balance'] = bal;
            }
            await _cache.cacheBookDetails(bookId, cached);
            break;
          }
        }
      }
    }
  }
}
