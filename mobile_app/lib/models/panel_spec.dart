class PanelSpec {
  final String panelName;
  final String enclosureSize; // e.g. 600x400x250 mm
  final String ipRating; // IP42, IP54, IP55, IP65
  final String sheetThickness; // 1.6 mm, 2.0 mm
  final String switchgearBrand; // Schneider, ABB, Siemens, L&T
  final String busbarMaterial; // Copper, Aluminum
  final double currentRatingAmps;

  const PanelSpec({
    required this.panelName,
    required this.enclosureSize,
    required this.ipRating,
    required this.sheetThickness,
    required this.switchgearBrand,
    required this.busbarMaterial,
    required this.currentRatingAmps,
  });
}
