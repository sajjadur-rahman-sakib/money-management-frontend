import 'package:cashflow/models/book_model.dart';
import 'package:cashflow/services/book_service.dart';

class BookController {
  final BookService _bookService = BookService();

  Future<List<Book>> fetchBooks() async {
    return await _bookService.getBooks();
  }

  Future<Book> createBook(String name) async {
    return await _bookService.createBook(name);
  }

  Future<Book> updateBook(String bookId, String name) async {
    return await _bookService.updateBook(bookId, name);
  }

  Future<void> deleteBook(String bookId) async {
    await _bookService.deleteBook(bookId);
  }
}
