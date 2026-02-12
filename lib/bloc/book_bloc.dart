import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/controllers/book_controller.dart';
import 'package:money/controllers/transaction_controller.dart';
import 'package:money/models/book_model.dart';
import 'package:money/services/connectivity_service.dart';
import 'package:money/utils/error_parser.dart';

abstract class BookEvent {}

class FetchBooksEvent extends BookEvent {}

class CreateBookEvent extends BookEvent {
  final String name;
  CreateBookEvent(this.name);
}

class UpdateBookEvent extends BookEvent {
  final String bookId;
  final String name;
  UpdateBookEvent(this.bookId, this.name);
}

class DeleteBookEvent extends BookEvent {
  final String bookId;
  DeleteBookEvent(this.bookId);
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

class UpdateTransactionEvent extends BookEvent {
  final String bookId;
  final String transactionId;
  final double amount;
  final String description;
  UpdateTransactionEvent(
    this.bookId,
    this.transactionId,
    this.amount,
    this.description,
  );
}

class DeleteTransactionEvent extends BookEvent {
  final String bookId;
  final String transactionId;
  DeleteTransactionEvent(this.bookId, this.transactionId);
}

abstract class BookState {}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BooksLoaded extends BookState {
  final List<Book> books;
  final bool isOffline;
  BooksLoaded(this.books, {this.isOffline = false});
}

class BookDetailsLoaded extends BookState {
  final Map<String, dynamic> data;
  final bool isOffline;
  BookDetailsLoaded(this.data, {this.isOffline = false});
}

class BookError extends BookState {
  final String message;
  BookError(this.message);
}

class BookOfflineSuccess extends BookState {
  final String message;
  BookOfflineSuccess(this.message);
}

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookController _bookController = BookController();
  final TransactionController _transactionController = TransactionController();
  final ConnectivityService _connectivity = ConnectivityService();

  BookBloc() : super(BookInitial()) {
    on<FetchBooksEvent>((event, emit) async {
      emit(BookLoading());
      try {
        final isOffline = !await _connectivity.checkConnectivity();
        var books = await _bookController.fetchBooks();
        emit(BooksLoaded(books, isOffline: isOffline));
      } catch (e) {
        emit(BookError(parseExceptionMessage(e)));
      }
    });

    on<CreateBookEvent>((event, emit) async {
      emit(BookLoading());
      try {
        await _bookController.createBook(event.name);
        final isOffline = !_connectivity.isConnected;
        if (isOffline) {
          emit(
            BookOfflineSuccess('Book saved offline. Will sync when online.'),
          );
        }
        add(FetchBooksEvent());
      } catch (e) {
        emit(BookError(parseExceptionMessage(e)));
      }
    });

    on<FetchBookDetailsEvent>((event, emit) async {
      emit(BookLoading());
      try {
        final isOffline = !await _connectivity.checkConnectivity();
        var data = await _transactionController.fetchBookDetails(event.bookId);
        emit(BookDetailsLoaded(data, isOffline: isOffline));
      } catch (e) {
        emit(BookError(parseExceptionMessage(e)));
      }
    });

    on<UpdateBookEvent>((event, emit) async {
      emit(BookLoading());
      try {
        await _bookController.updateBook(event.bookId, event.name);
        final isOffline = !_connectivity.isConnected;
        if (isOffline) {
          emit(
            BookOfflineSuccess('Update saved offline. Will sync when online.'),
          );
        }
        add(FetchBooksEvent());
      } catch (e) {
        emit(BookError(parseExceptionMessage(e)));
      }
    });

    on<DeleteBookEvent>((event, emit) async {
      emit(BookLoading());
      try {
        await _bookController.deleteBook(event.bookId);
        final isOffline = !_connectivity.isConnected;
        if (isOffline) {
          emit(
            BookOfflineSuccess('Delete saved offline. Will sync when online.'),
          );
        }
        add(FetchBooksEvent());
      } catch (e) {
        emit(BookError(parseExceptionMessage(e)));
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
        final isOffline = !_connectivity.isConnected;
        if (isOffline) {
          emit(
            BookOfflineSuccess(
              'Transaction saved offline. Will sync when online.',
            ),
          );
        }
        add(FetchBookDetailsEvent(event.bookId));
      } catch (e) {
        emit(BookError(parseExceptionMessage(e)));
      }
    });

    on<UpdateTransactionEvent>((event, emit) async {
      emit(BookLoading());
      try {
        await _transactionController.updateTransaction(
          event.transactionId,
          event.amount,
          event.description,
        );
        final isOffline = !_connectivity.isConnected;
        if (isOffline) {
          emit(
            BookOfflineSuccess('Update saved offline. Will sync when online.'),
          );
        }
        add(FetchBookDetailsEvent(event.bookId));
      } catch (e) {
        emit(BookError(parseExceptionMessage(e)));
      }
    });

    on<DeleteTransactionEvent>((event, emit) async {
      emit(BookLoading());
      try {
        await _transactionController.deleteTransaction(event.transactionId);
        final isOffline = !_connectivity.isConnected;
        if (isOffline) {
          emit(
            BookOfflineSuccess('Delete saved offline. Will sync when online.'),
          );
        }
        add(FetchBookDetailsEvent(event.bookId));
      } catch (e) {
        emit(BookError(parseExceptionMessage(e)));
      }
    });
  }
}
