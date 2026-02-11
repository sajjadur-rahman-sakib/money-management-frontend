import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/controllers/transaction_controller.dart';
import 'package:money/utils/error_parser.dart';

abstract class TransactionEvent {}

class FetchTransactionEvent extends TransactionEvent {
  final String bookId;
  FetchTransactionEvent(this.bookId);
}

class CreateTransactionEvent extends TransactionEvent {
  final String bookId, type;
  final double amount;
  final String? description;
  CreateTransactionEvent(this.bookId, this.type, this.amount, this.description);
}

class UpdateTransactionEvent extends TransactionEvent {
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

class DeleteTransactionEvent extends TransactionEvent {
  final String bookId;
  final String transactionId;
  DeleteTransactionEvent(this.bookId, this.transactionId);
}

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final Map<String, dynamic> data;
  TransactionLoaded(this.data);
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionController _controller = TransactionController();

  TransactionBloc() : super(TransactionInitial()) {
    on<FetchTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        var data = await _controller.fetchBookDetails(event.bookId);
        emit(TransactionLoaded(data));
      } catch (e) {
        emit(TransactionError(parseExceptionMessage(e)));
      }
    });

    on<CreateTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        await _controller.createTransaction(
          event.bookId,
          event.type,
          event.amount,
          event.description,
        );
        add(FetchTransactionEvent(event.bookId));
      } catch (e) {
        emit(TransactionError(parseExceptionMessage(e)));
      }
    });

    on<UpdateTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        await _controller.updateTransaction(
          event.transactionId,
          event.amount,
          event.description,
        );
        add(FetchTransactionEvent(event.bookId));
      } catch (e) {
        emit(TransactionError(parseExceptionMessage(e)));
      }
    });

    on<DeleteTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        await _controller.deleteTransaction(event.transactionId);
        add(FetchTransactionEvent(event.bookId));
      } catch (e) {
        emit(TransactionError(parseExceptionMessage(e)));
      }
    });
  }
}
