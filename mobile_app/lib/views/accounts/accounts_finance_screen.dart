import 'package:flutter/material.dart';
import '../../models/financial_transaction.dart';
import '../../services/finance_service.dart';
import '../widgets/mobile_header.dart';

class AccountsFinanceScreen extends StatefulWidget {
  const AccountsFinanceScreen({super.key});

  @override
  State<AccountsFinanceScreen> createState() => _AccountsFinanceScreenState();
}

class _AccountsFinanceScreenState extends State<AccountsFinanceScreen> {
  final FinanceService _financeService = FinanceService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _financeService,
      builder: (context, _) {
        final transactions = _financeService.transactions;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: const MobileHeader(
            title: 'Accounts & Finance',
            subtitle: 'Ledgers & Cash Flow Summary',
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Balance Overview Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade900.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Net Account Profit / Loss',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_financeService.netProfit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetric('Total Revenue', '₹${_financeService.totalIncome.toStringAsFixed(0)}'),
                        _buildMetric('Total Expenses', '₹${_financeService.totalExpense.toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Recent Financial Transactions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...transactions.map((txn) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: txn.isIncome
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          txn.isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: txn.isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(txn.category,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                          '${txn.voucherNo} • ${txn.paymentMode}\n${txn.description}',
                          style: const TextStyle(fontSize: 11)),
                      trailing: Text(
                        '${txn.isIncome ? '+' : '-'}₹${txn.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: txn.isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  )),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF059669),
            foregroundColor: Colors.white,
            onPressed: () => _showAddTransactionDialog(context),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final catCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    TransactionType type = TransactionType.expense;
    String mode = 'Bank Transfer';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Record Financial Transaction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                        value: TransactionType.income, label: Text('Income (+)')),
                    ButtonSegment(
                        value: TransactionType.expense, label: Text('Expense (-)')),
                  ],
                  selected: {type},
                  onSelectionChanged: (val) =>
                      setModalState(() => type = val.first),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: catCtrl,
                  decoration: const InputDecoration(labelText: 'Category (e.g. Sales, Raw Material)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: mode,
                  items: ['Bank Transfer', 'Cash', 'UPI', 'Cheque']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (val) => setModalState(() => mode = val!),
                  decoration: const InputDecoration(labelText: 'Payment Mode'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (catCtrl.text.isNotEmpty && amtCtrl.text.isNotEmpty) {
                        _financeService.addTransaction(
                          FinancialTransaction(
                            id: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            date: DateTime.now(),
                            voucherNo: 'VOUCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            category: catCtrl.text.trim(),
                            type: type,
                            amount: double.tryParse(amtCtrl.text) ?? 0.0,
                            paymentMode: mode,
                            description: descCtrl.text.trim(),
                          ),
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Save Transaction'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
