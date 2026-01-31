import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/controllers/book_controller.dart';
import 'package:money/models/book_model.dart';

abstract class BookEvent {}

class FetchBooksEvent extends BookEvent {}

class CreateBookEvent extends BookEvent {
  final String name;
  CreateBookEvent(this.name);
}

abstract class BookState {}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BooksLoaded extends BookState {
  final List<Book> books;
  BooksLoaded(this.books);
}

class BookError extends BookState {
  final String message;
  BookError(this.message);
}

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookController _controller = BookController();

  BookBloc() : super(BookInitial()) {
    on<FetchBooksEvent>((event, emit) async {
      emit(BookLoading());
      try {
        var books = await _controller.fetchBooks();
        emit(BooksLoaded(books));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    });

    on<CreateBookEvent>((event, emit) async {
      emit(BookLoading());
      try {
        await _controller.createBook(event.name);
        add(FetchBooksEvent());
      } catch (e) {
        emit(BookError(e.toString()));
      }
    });
  }
}
