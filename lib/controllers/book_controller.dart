import 'package:money/models/book_model.dart';
import 'package:money/services/book_service.dart';

class BookController {
  final BookService _bookService = BookService();

  Future<List<Book>> fetchBooks() async {
    return await _bookService.getBooks();
  }

  Future<Book> createBook(String name) async {
    return await _bookService.createBook(name);
  }
}
