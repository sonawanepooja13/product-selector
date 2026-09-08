import '../models/product_configuration.dart';
import 'bom_calculation_engine.dart';

class ProductSearchResult {
  final bool isFound;
  final double? basePrice;
  final double? finalPrice;
  final double customerAdjustmentPercent;
  final String? matchedDetails;

  const ProductSearchResult({
    required this.isFound,
    this.basePrice,
    this.finalPrice,
    this.customerAdjustmentPercent = 0.0,
    this.matchedDetails,
  });
}

class ProductCatalogService {
  // Singleton pattern for centralized mobile state
  static final ProductCatalogService _instance =
      ProductCatalogService._internal();
  factory ProductCatalogService() => _instance;
  ProductCatalogService._internal() {
    _initDefaults();
  }

  late List<ProductConfiguration> _products;
  late List<Customer> _customers;
  late List<CatalogItem> _catalogItems;

  void _initDefaults() {
    _products = [
      const ProductConfiguration(
        pumpCurrent: 10.0,
        numPumps: 2,
        numVfd: 1,
        bypass: 'With Bypass',
        panelType: 'Indoor',
        panelSize: '600x400',
        panelClass: 'Industrial',
        mainIncomer: 'Yes',
        olrRequired: 'Yes',
        indicatorLight: 'Yes',
        price: 125000.00,
      ),
      const ProductConfiguration(
        pumpCurrent: 15.0,
        numPumps: 3,
        numVfd: 1,
        bypass: 'With Bypass',
        panelType: 'Indoor',
        panelSize: '800x600',
        panelClass: 'Industrial',
        mainIncomer: 'Yes',
        olrRequired: 'No',
        indicatorLight: 'Yes',
        price: 185000.00,
      ),
      const ProductConfiguration(
        pumpCurrent: 7.5,
        numPumps: 2,
        numVfd: 0,
        bypass: 'Without Bypass',
        panelType: 'Indoor',
        panelSize: '400x300',
        panelClass: 'Domestic',
        mainIncomer: 'Yes',
        olrRequired: 'Yes',
        indicatorLight: 'No',
        price: 68000.00,
      ),
      const ProductConfiguration(
        pumpCurrent: 20.0,
        numPumps: 4,
        numVfd: 2,
        bypass: 'With Bypass',
        panelType: 'Outdoor',
        panelSize: '1000x800',
        panelClass: 'Industrial',
        mainIncomer: 'Yes',
        olrRequired: 'Yes',
        indicatorLight: 'Yes',
        price: 340000.00,
      ),
    ];

    _customers = [
      const Customer(name: 'Standard Customer', percentage: 0.0),
      const Customer(name: 'Industrial Contractor Corp', percentage: -8.0),
      const Customer(name: 'Municipal Water Works', percentage: -5.0),
      const Customer(name: 'Apex Builders & Infra', percentage: 10.0),
      const Customer(name: 'Retail Walk-in Buyer', percentage: 15.0),
    ];

    _catalogItems = List.from(BomCalculationEngine.defaultCatalog);
  }

  List<ProductConfiguration> get products => List.unmodifiable(_products);
  List<Customer> get customers => List.unmodifiable(_customers);
  List<CatalogItem> get catalogItems => List.unmodifiable(_catalogItems);

  ProductSearchResult searchPrice(
    ProductConfiguration query,
    Customer customer,
  ) {
    String clean(dynamic val) => val?.toString().trim().toLowerCase() ?? '';

    ProductConfiguration? match;
    for (final p in _products) {
      final currentMatch = (p.pumpCurrent - query.pumpCurrent).abs() < 0.01;
      final pumpsMatch = p.numPumps == query.numPumps;
      final vfdMatch = p.numVfd == query.numVfd;
      final bypassMatch = clean(p.bypass) == clean(query.bypass);
      final typeMatch = clean(p.panelType) == clean(query.panelType);
      final sizeMatch = clean(p.panelSize) == clean(query.panelSize);
      final classMatch = clean(p.panelClass) == clean(query.panelClass);
      final incomerMatch = clean(p.mainIncomer) == clean(query.mainIncomer);
      final olrMatch = clean(p.olrRequired) == clean(query.olrRequired);
      final lightMatch = clean(p.indicatorLight) == clean(query.indicatorLight);

      if (currentMatch &&
          pumpsMatch &&
          vfdMatch &&
          bypassMatch &&
          typeMatch &&
          sizeMatch &&
          classMatch &&
          incomerMatch &&
          olrMatch &&
          lightMatch) {
        match = p;
        break;
      }
    }

    if (match != null) {
      final basePrice = match.price;
      final finalPrice =
          basePrice + (basePrice * (customer.percentage / 100.0));
      return ProductSearchResult(
        isFound: true,
        basePrice: basePrice,
        finalPrice: finalPrice,
        customerAdjustmentPercent: customer.percentage,
        matchedDetails:
            '${match.numPumps}P x ${match.numVfd}VFD (${match.pumpCurrent}A, ${match.panelSize})',
      );
    } else {
      return ProductSearchResult(
        isFound: false,
        customerAdjustmentPercent: customer.percentage,
      );
    }
  }

  void addProduct(ProductConfiguration config) {
    _products.insert(0, config);
  }

  void addCustomer(Customer customer) {
    _customers.add(customer);
  }

  void addCatalogItem(CatalogItem item) {
    _catalogItems.insert(0, item);
  }
}
