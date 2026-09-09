import 'package:flutter/material.dart';
import '../../models/vendor_item.dart';
import '../widgets/mobile_header.dart';

class SupplyChainScreen extends StatelessWidget {
  const SupplyChainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vendors = [
      const VendorItem(
        vendorId: 'VEND-001',
        vendorName: 'Schneider Electric India Pvt Ltd',
        category: 'Switchgear & Breakers',
        rating: 4.9,
        phone: '+91 1800 103 0011',
        gstin: '27AAACS1234F1Z0',
      ),
      const VendorItem(
        vendorId: 'VEND-002',
        vendorName: 'Siemens Industrial Automation',
        category: 'Contactors & Relays',
        rating: 4.8,
        phone: '+91 22 3966 3000',
        gstin: '27AAAAB1234A1Z5',
      ),
    ];

    final dispatches = [
      OutwardDispatch(
        dispatchId: 'DISP-20260822-01',
        quotationNo: 'Q-20260822-001',
        customerName: 'GreenTech Eco Solutions',
        dispatchDate: DateTime.now().subtract(const Duration(days: 1)),
        transporter: 'VRL Logistics',
        trackingNo: 'VRL99812401',
        status: 'In Transit',
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: const MobileHeader(
          title: 'Supply Chain & Logistics',
          subtitle: 'Vendor Directory & Outward Dispatch',
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Color(0xFF0891B2),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF0891B2),
                tabs: [
                  Tab(text: 'Vendor Directory'),
                  Tab(text: 'Outward Dispatches'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Vendors Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vendors.length,
                    itemBuilder: (context, index) {
                      final v = vendors[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(v.vendorName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          subtitle: Text(
                              'Category: ${v.category}\nGSTIN: ${v.gstin} • Tel: ${v.phone}',
                              style: const TextStyle(fontSize: 12)),
                          trailing: Chip(
                            avatar: const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 18),
                            label: Text('${v.rating}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.amber.shade50,
                          ),
                        ),
                      );
                    },
                  ),

                  // Dispatches Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dispatches.length,
                    itemBuilder: (context, index) {
                      final d = dispatches[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(d.dispatchId,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF0891B2))),
                                  Chip(
                                    label: Text(d.status,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                    backgroundColor: Colors.blue.shade50,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Customer: ${d.customerName}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                'Quote: ${d.quotationNo} • Carrier: ${d.transporter} (AWB: ${d.trackingNo})',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
