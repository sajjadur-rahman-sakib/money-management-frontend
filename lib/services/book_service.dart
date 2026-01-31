import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money/models/book_model.dart';
import 'package:money/services/auth_service.dart';
import 'package:money/utils/app_urls.dart';

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
    throw Exception('Failed to load books');
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
    throw Exception('Failed to create book');
  }
}
