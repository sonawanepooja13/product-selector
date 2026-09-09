class VendorItem {
  final String vendorId;
  final String vendorName;
  final String category;
  final double rating; // 1.0 - 5.0
  final String phone;
  final String gstin;

  const VendorItem({
    required this.vendorId,
    required this.vendorName,
    required this.category,
    required this.rating,
    required this.phone,
    required this.gstin,
  });
}

class OutwardDispatch {
  final String dispatchId;
  final String quotationNo;
  final String customerName;
  final DateTime dispatchDate;
  final String transporter;
  final String trackingNo;
  final String status; // Dispatched, In Transit, Delivered

  const OutwardDispatch({
    required this.dispatchId,
    required this.quotationNo,
    required this.customerName,
    required this.dispatchDate,
    required this.transporter,
    required this.trackingNo,
    required this.status,
  });
}
