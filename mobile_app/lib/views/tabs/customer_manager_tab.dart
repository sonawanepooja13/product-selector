import 'package:flutter/material.dart';
import '../../models/product_configuration.dart';
import '../../services/product_catalog_service.dart';

class CustomerManagerTab extends StatefulWidget {
  const CustomerManagerTab({super.key});

  @override
  State<CustomerManagerTab> createState() => _CustomerManagerTabState();
}

class _CustomerManagerTabState extends State<CustomerManagerTab> {
  final ProductCatalogService _catalogService = ProductCatalogService();

  void _openAddCustomerSheet() {
    final nameController = TextEditingController();
    final percentController = TextEditingController(text: '0.0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Register New Customer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Add customer with custom markup or discount rate.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer / Company Name',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: percentController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price Adjustment (%)',
                  hintText: 'e.g. 10 for +10% markup, -5 for 5% discount',
                  prefixIcon: Icon(Icons.percent_rounded),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5D9F),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final pct = double.tryParse(percentController.text.trim());
                    if (name.isEmpty || pct == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill valid customer details.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    _catalogService.addCustomer(Customer(name: name, percentage: pct));
                    Navigator.pop(ctx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registered customer $name!')),
                    );
                  },
                  child: const Text('Save Customer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = _catalogService.customers;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCustomerSheet,
        backgroundColor: const Color(0xFF2F5D9F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Customer'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: customers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final c = customers[index];
          final isDiscount = c.percentage < 0;
          final isMarkup = c.percentage > 0;
          final sign = c.percentage >= 0 ? '+' : '';

          Color badgeBg = Colors.grey.shade100;
          Color badgeColor = Colors.grey.shade700;
          if (isDiscount) {
            badgeBg = Colors.green.shade50;
            badgeColor = Colors.green.shade800;
          } else if (isMarkup) {
            badgeBg = Colors.amber.shade50;
            badgeColor = Colors.amber.shade900;
          }

          return Card(
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    const Color(0xFF2F5D9F).withValues(alpha: 0.12),
                child: Text(
                  c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F5D9F),
                  ),
                ),
              ),
              title: Text(
                c.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isDiscount
                    ? 'Discounted client tier'
                    : isMarkup
                        ? 'Markup retail tier'
                        : 'Standard base pricing',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$sign${c.percentage}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
