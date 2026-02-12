import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PendingOperation {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  PendingOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'data': data,
    'created_at': createdAt.toIso8601String(),
  };

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class OfflineCacheService {
  static final OfflineCacheService _instance = OfflineCacheService._();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._();

  static const String _booksKey = 'cached_books';
  static const String _bookDetailsPrefix = 'cached_book_details_';
  static const String _pendingOpsKey = 'pending_operations';

  Future<void> cacheBooks(List<Map<String, dynamic>> books) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_booksKey, jsonEncode(books));
  }

  Future<List<Map<String, dynamic>>?> getCachedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_booksKey);
    if (data != null) {
      final list = jsonDecode(data) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return null;
  }

  Future<void> cacheBookDetails(
    String bookId,
    Map<String, dynamic> details,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_bookDetailsPrefix$bookId', jsonEncode(details));
  }

  Future<Map<String, dynamic>?> getCachedBookDetails(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_bookDetailsPrefix$bookId');
    if (data != null) {
      return Map<String, dynamic>.from(jsonDecode(data));
    }
    return null;
  }

  Future<List<PendingOperation>> getPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_pendingOpsKey);
    if (data != null) {
      final list = jsonDecode(data) as List;
      return list.map((e) => PendingOperation.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> addPendingOperation(PendingOperation op) async {
    final ops = await getPendingOperations();
    ops.add(op);
    await _savePendingOperations(ops);
  }

  Future<void> removePendingOperation(String operationId) async {
    final ops = await getPendingOperations();
    ops.removeWhere((op) => op.id == operationId);
    await _savePendingOperations(ops);
  }

  Future<void> clearPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOpsKey);
  }

  Future<bool> hasPendingOperations() async {
    final ops = await getPendingOperations();
    return ops.isNotEmpty;
  }

  Future<void> _savePendingOperations(List<PendingOperation> ops) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingOpsKey,
      jsonEncode(ops.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_booksKey);
    await prefs.remove(_pendingOpsKey);
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_bookDetailsPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
