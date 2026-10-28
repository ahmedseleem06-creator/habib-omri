class ServiceOffer {
  final String id;
  final String title;
  final String category;
  final String description;
  final double price;
  final double? originalPrice;
  final String badge;
  final List<String> features;

  const ServiceOffer({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.badge,
    required this.features,
  });
}
