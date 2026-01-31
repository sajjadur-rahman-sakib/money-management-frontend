class Transaction {
  final String id;
  final String bookId;
  final String type;
  final double amount;
  final String? description;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.bookId,
    required this.type,
    required this.amount,
    this.description,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      bookId: json['book_id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
