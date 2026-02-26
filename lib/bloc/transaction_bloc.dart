import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashflow/controllers/transaction_controller.dart';
import 'package:cashflow/services/connectivity_service.dart';
import 'package:cashflow/utils/error_parser.dart';

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
  final bool isOffline;
  TransactionLoaded(this.data, {this.isOffline = false});
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}

class TransactionOfflineSuccess extends TransactionState {
  final String message;
  TransactionOfflineSuccess(this.message);
}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionController _controller = TransactionController();
  final ConnectivityService _connectivity = ConnectivityService();

  TransactionBloc() : super(TransactionInitial()) {
    on<FetchTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        final isOffline = !await _connectivity.checkConnectivity();
        var data = await _controller.fetchBookDetails(event.bookId);
        emit(TransactionLoaded(data, isOffline: isOffline));
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
        final isOffline = !_connectivity.isConnected;
        if (isOffline) {
          emit(
            TransactionOfflineSuccess(
              'Transaction saved offline. Will sync when online.',
            ),
          );
        }
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
        final isOffline = !_connectivity.isConnected;
        if (isOffline) {
          emit(
            TransactionOfflineSuccess(
              'Update saved offline. Will sync when online.',
            ),
          );
        }
        add(FetchTransactionEvent(event.bookId));
      } catch (e) {
        emit(TransactionError(parseExceptionMessage(e)));
      }
    });

    on<DeleteTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        await _controller.deleteTransaction(event.transactionId);
        final isOffline = !_connectivity.isConnected;
        if (isOffline) {
          emit(
            TransactionOfflineSuccess(
              'Delete saved offline. Will sync when online.',
            ),
          );
        }
        add(FetchTransactionEvent(event.bookId));
      } catch (e) {
        emit(TransactionError(parseExceptionMessage(e)));
      }
    });
  }
}
