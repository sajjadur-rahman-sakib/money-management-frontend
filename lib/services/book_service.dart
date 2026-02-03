import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money/models/book_model.dart';
import 'package:money/services/auth_service.dart';
import 'package:money/utils/app_urls.dart';
import 'package:money/utils/error_parser.dart';

class BookService {
  final AuthService _authService = AuthService();

  Future<List<Book>> getBooks() async {
    String? token = await _authService.getToken();
    var response = await http.get(
      AppUrls.uri(AppUrls.getBooks),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Book.fromJson(e)).toList();
    }
    throw Exception(
      parseErrorMessage(response.body, fallback: 'Failed to load books'),
    );
  }

  Future<Book> createBook(String name) async {
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
      return Book.fromJson(jsonDecode(response.body));
    }
    throw Exception(
      parseErrorMessage(response.body, fallback: 'Failed to create book'),
    );
  }

  Future<Book> updateBook(String bookId, String name) async {
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
    throw Exception(
      parseErrorMessage(response.body, fallback: 'Failed to update book'),
    );
  }

  Future<void> deleteBook(String bookId) async {
    String? token = await _authService.getToken();
    var response = await http.post(
      AppUrls.uri(AppUrls.deleteBook),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'book_id': bookId}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        parseErrorMessage(response.body, fallback: 'Failed to delete book'),
      );
    }
  }
}
