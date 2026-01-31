import 'package:money/services/transaction_service.dart';

class TransactionController {
  final TransactionService _transactionService = TransactionService();

  Future<Map<String, dynamic>> fetchBookDetails(String bookId) async {
    return await _transactionService.getBookDetails(bookId);
  }

  Future<void> createTransaction(
    String bookId,
    String type,
    double amount,
    String? description,
  ) async {
    await _transactionService.createTransaction(
      bookId,
      type,
      amount,
      description,
    );
  }
}
