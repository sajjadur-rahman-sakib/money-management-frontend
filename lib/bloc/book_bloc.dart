import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/controllers/book_controller.dart';
import 'package:money/controllers/transaction_controller.dart';
import 'package:money/models/book_model.dart';

abstract class BookEvent {}

class FetchBooksEvent extends BookEvent {}

class CreateBookEvent extends BookEvent {
  final String name;
  CreateBookEvent(this.name);
}

class FetchBookDetailsEvent extends BookEvent {
  final String bookId;
  FetchBookDetailsEvent(this.bookId);
}

class CreateTransactionEvent extends BookEvent {
  final String bookId, type;
  final double amount;
  final String? description;
  CreateTransactionEvent(this.bookId, this.type, this.amount, this.description);
}

abstract class BookState {}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BooksLoaded extends BookState {
  final List<Book> books;
  BooksLoaded(this.books);
}

class BookDetailsLoaded extends BookState {
  final Map<String, dynamic> data;
  BookDetailsLoaded(this.data);
}

class BookError extends BookState {
  final String message;
  BookError(this.message);
}

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookController _bookController = BookController();
  final TransactionController _transactionController = TransactionController();

  BookBloc() : super(BookInitial()) {
    on<FetchBooksEvent>((event, emit) async {
      emit(BookLoading());
      try {
        var books = await _bookController.fetchBooks();
        emit(BooksLoaded(books));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    });

    on<CreateBookEvent>((event, emit) async {
      emit(BookLoading());
      try {
        await _bookController.createBook(event.name);
        add(FetchBooksEvent());
      } catch (e) {
        emit(BookError(e.toString()));
      }
    });

    on<FetchBookDetailsEvent>((event, emit) async {
      emit(BookLoading());
      try {
        var data = await _transactionController.fetchBookDetails(event.bookId);
        emit(BookDetailsLoaded(data));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    });

    on<CreateTransactionEvent>((event, emit) async {
      emit(BookLoading());
      try {
        await _transactionController.createTransaction(
          event.bookId,
          event.type,
          event.amount,
          event.description,
        );
        add(FetchBookDetailsEvent(event.bookId));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    });
  }
}
