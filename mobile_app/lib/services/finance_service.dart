import 'package:flutter/foundation.dart';
import '../models/financial_transaction.dart';

class FinanceService extends ChangeNotifier {
  static final FinanceService _instance = FinanceService._internal();
  factory FinanceService() => _instance;

  FinanceService._internal() {
    _initTransactions();
  }

  final List<FinancialTransaction> _transactions = [];
  List<FinancialTransaction> get transactions => List.unmodifiable(_transactions);

  void _initTransactions() {
    _transactions.addAll([
      FinancialTransaction(
        id: 'TXN-501',
        date: DateTime.now().subtract(const Duration(days: 1)),
        voucherNo: 'INV-2026-089',
        category: 'Sales Invoice',
        type: TransactionType.income,
        amount: 285000,
        paymentMode: 'Bank Transfer',
        description: 'Payment received from Apex Infrastructure for Booster Panel',
      ),
      FinancialTransaction(
        id: 'TXN-502',
        date: DateTime.now().subtract(const Duration(days: 2)),
        voucherNo: 'PO-RAW-042',
        category: 'Raw Material Procurement',
        type: TransactionType.expense,
        amount: 112000,
        paymentMode: 'Bank Transfer',
        description: 'Purchased Siemens Contactors & Schneider MCBs',
      ),
      FinancialTransaction(
        id: 'TXN-503',
        date: DateTime.now().subtract(const Duration(days: 5)),
        voucherNo: 'SAL-2026-08',
        category: 'Monthly Payroll',
        type: TransactionType.expense,
        amount: 145000,
        paymentMode: 'Bank Transfer',
        description: 'Factory technician & engineering staff monthly salaries',
      ),
    ]);
  }

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get netProfit => totalIncome - totalExpense;

  void addTransaction(FinancialTransaction txn) {
    _transactions.insert(0, txn);
    notifyListeners();
  }
}
