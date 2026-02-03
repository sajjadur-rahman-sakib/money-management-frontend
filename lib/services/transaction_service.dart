import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money/services/auth_service.dart';
import 'package:money/utils/app_urls.dart';

class TransactionService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getBookDetails(String bookId) async {
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
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load book details');
  }

  Future<void> createTransaction(
    String bookId,
    String type,
    double amount,
    String? description,
  ) async {
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
    if (response.statusCode != 200) {
      throw Exception('Failed to create transaction');
    }
  }

  Future<void> updateTransaction(
    String transactionId,
    double amount,
    String description,
  ) async {
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
    if (response.statusCode != 200) {
      throw Exception('Failed to update transaction');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    String? token = await _authService.getToken();
    var response = await http.post(
      AppUrls.uri(AppUrls.deleteTransaction),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'transaction_id': transactionId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction');
    }
  }
}
