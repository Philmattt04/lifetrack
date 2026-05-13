enum TransactionType { income, expense }

enum BudgetCategory {
  housing, food, transport, health, entertainment, savings, other;

  String get label => switch (this) {
        BudgetCategory.housing => 'Housing',
        BudgetCategory.food => 'Food & Dining',
        BudgetCategory.transport => 'Transport',
        BudgetCategory.health => 'Health',
        BudgetCategory.entertainment => 'Entertainment',
        BudgetCategory.savings => 'Savings',
        BudgetCategory.other => 'Other',
      };

  String get emoji => switch (this) {
        BudgetCategory.housing => '🏠',
        BudgetCategory.food => '🍔',
        BudgetCategory.transport => '🚗',
        BudgetCategory.health => '💊',
        BudgetCategory.entertainment => '🎬',
        BudgetCategory.savings => '💰',
        BudgetCategory.other => '📦',
      };
}

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final BudgetCategory category;
  final String note;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  Transaction copyWith({
    TransactionType? type, double? amount, BudgetCategory? category,
    String? note, DateTime? date,
  }) =>
      Transaction(
        id: id, type: type ?? this.type, amount: amount ?? this.amount,
        category: category ?? this.category, note: note ?? this.note,
        date: date ?? this.date,
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'type': type.name, 'amount': amount,
        'category': category.name, 'note': note,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromMap(Map<String, dynamic> m) => Transaction(
        id: m['id'] as String,
        type: TransactionType.values.firstWhere((t) => t.name == m['type']),
        amount: (m['amount'] as num).toDouble(),
        category: BudgetCategory.values.firstWhere(
          (c) => c.name == m['category'],
          orElse: () => BudgetCategory.other,
        ),
        note: m['note'] as String,
        date: DateTime.parse(m['date'] as String),
      );
}
