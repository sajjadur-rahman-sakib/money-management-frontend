class Book {
  final String id;
  final String name;
  final String userId;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Book({
    required this.id,
    required this.name,
    required this.userId,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      name: json['name'],
      userId: json['user_id'],
      balance: (json['balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
