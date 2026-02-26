import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cashflow/models/book_model.dart';
import 'package:cashflow/services/auth_service.dart';
import 'package:cashflow/services/connectivity_service.dart';
import 'package:cashflow/services/cache_service.dart';
import 'package:cashflow/services/sync_service.dart';
import 'package:cashflow/utils/app_urls.dart';
import 'package:uuid/uuid.dart';

class BookService {
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivity = ConnectivityService();
  final OfflineCacheService _cache = OfflineCacheService();

  Future<List<Book>> getBooks() async {
    final isOnline = await _connectivity.checkConnectivity();

    if (isOnline) {
      try {
        await SyncService().syncPendingOperations();
      } catch (_) {}

      final hasPending = await _cache.hasPendingOperations();
      if (!hasPending) {
        try {
          String? token = await _authService.getToken();
          var response = await http.get(
            AppUrls.uri(AppUrls.getBooks),
            headers: {'Authorization': 'Bearer $token'},
          );
          if (response.statusCode == 200) {
            List data = jsonDecode(response.body);
            await _cache.cacheBooks(
              data.map((e) => Map<String, dynamic>.from(e)).toList(),
            );
            return data.map((e) => Book.fromJson(e)).toList();
          }
        } catch (_) {}
      }
    }

    final cached = await _cache.getCachedBooks();
    if (cached != null) {
      return cached.map((e) => Book.fromJson(e)).toList();
    }
    return [];
  }

  Future<Book> createBook(String name) async {
    final isOnline = await _connectivity.checkConnectivity();

    if (isOnline) {
      try {
        String? token = await _authService.getToken();
        var response = await http.post(
          AppUrls.uri(AppUrls.createBook),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'name': name}),
        );
        if (response.statusCode == 200) {
          final book = Book.fromJson(jsonDecode(response.body));
          return book;
        }
      } catch (_) {}
    }

    {
      final tempId = const Uuid().v4();
      await _cache.addPendingOperation(
        PendingOperation(
          id: tempId,
          type: 'create_book',
          data: {'name': name},
          createdAt: DateTime.now(),
        ),
      );

      final tempBook = {
        'id': tempId,
        'name': name,
        'user_id': '',
        'balance': 0.0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      final cached = await _cache.getCachedBooks() ?? [];
      cached.add(tempBook);
      await _cache.cacheBooks(cached);

      return Book.fromJson(tempBook);
    }
  }

  Future<Book> updateBook(String bookId, String name) async {
    final isOnline = await _connectivity.checkConnectivity();

    if (isOnline) {
      try {
        String? token = await _authService.getToken();
        var response = await http.post(
          AppUrls.uri(AppUrls.updateBook),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'book_id': bookId, 'name': name}),
        );
        if (response.statusCode == 200) {
          return Book.fromJson(jsonDecode(response.body));
        }
      } catch (_) {}
    }

    {
      await _cache.addPendingOperation(
        PendingOperation(
          id: const Uuid().v4(),
          type: 'update_book',
          data: {'book_id': bookId, 'name': name},
          createdAt: DateTime.now(),
        ),
      );

      final cached = await _cache.getCachedBooks() ?? [];
      for (int i = 0; i < cached.length; i++) {
        if (cached[i]['id'] == bookId) {
          cached[i]['name'] = name;
          cached[i]['updated_at'] = DateTime.now().toIso8601String();
          break;
        }
      }
      await _cache.cacheBooks(cached);

      return Book.fromJson(cached.firstWhere((b) => b['id'] == bookId));
    }
  }

  Future<void> deleteBook(String bookId) async {
    final isOnline = await _connectivity.checkConnectivity();

    if (isOnline) {
      try {
        String? token = await _authService.getToken();
        var response = await http.post(
          AppUrls.uri(AppUrls.deleteBook),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'book_id': bookId}),
        );
        if (response.statusCode == 200) return;
      } catch (_) {}
    }

    {
      await _cache.addPendingOperation(
        PendingOperation(
          id: const Uuid().v4(),
          type: 'delete_book',
          data: {'book_id': bookId},
          createdAt: DateTime.now(),
        ),
      );

      final cached = await _cache.getCachedBooks() ?? [];
      cached.removeWhere((b) => b['id'] == bookId);
      await _cache.cacheBooks(cached);
    }
  }
}
