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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['product_name'] ?? json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['selling_price'] ?? json['price'] ?? 0.0).toDouble(),
      unit: json['volume'] ?? json['unit'] ?? '',
      imageUrl: json['product_images'] ?? json['imageUrl'] ?? '',
      inStock: json['stock_status'] == 'in_stock' || (json['inStock'] ?? true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty && !id.startsWith('P-')) '_id': id,
      'product_name': name,
      'category': category,
      'selling_price': price,
      'volume': unit,
      'product_images': imageUrl,
      'stock_status': inStock ? 'in_stock' : 'out_of_stock',
    };
  }
}
