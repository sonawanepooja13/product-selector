enum TransactionType { income, expense }

class FinancialTransaction {
  final String id;
  final DateTime date;
  final String voucherNo;
  final String category; // Sales Invoice, Component Purchase, Salary, Rent, Utility
  final TransactionType type;
  final double amount;
  final String paymentMode; // Bank Transfer, Cash, UPI, Cheque
  final String description;

  const FinancialTransaction({
    required this.id,
    required this.date,
    required this.voucherNo,
    required this.category,
    required this.type,
    required this.amount,
    required this.paymentMode,
    required this.description,
  });

  bool get isIncome => type == TransactionType.income;
}
