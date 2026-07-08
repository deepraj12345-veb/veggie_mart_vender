class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String imageUrl;
  final bool inStock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.imageUrl,
    this.inStock = true,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? unit,
    String? imageUrl,
    bool? inStock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      inStock: inStock ?? this.inStock,
    );
  }
}
