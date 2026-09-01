class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String imageUrl;
  final bool inStock;
  final String? vendorId;
  final String? vendorShopName;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.imageUrl,
    this.inStock = true,
    this.vendorId,
    this.vendorShopName,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? unit,
    String? imageUrl,
    bool? inStock,
    String? vendorId,
    String? vendorShopName,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      inStock: inStock ?? this.inStock,
      vendorId: vendorId ?? this.vendorId,
      vendorShopName: vendorShopName ?? this.vendorShopName,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String img = '';
    if (json['product_image'] != null && json['product_image'].toString().isNotEmpty) {
      img = json['product_image'].toString();
    } else if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      img = json['image_url'].toString();
    } else if (json['product_images'] != null && json['product_images'].toString().isNotEmpty) {
      img = json['product_images'].toString();
    } else if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      img = json['imageUrl'].toString();
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      img = (json['images'] as List).first.toString();
    }

    String vId = '';
    if (json['vendor_id'] != null) {
      if (json['vendor_id'] is Map) {
        vId = (json['vendor_id']['_id'] ?? json['vendor_id']['id'] ?? '').toString();
      } else {
        vId = json['vendor_id'].toString();
      }
    } else if (json['vendorId'] != null) {
      vId = json['vendorId'].toString();
    }

    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['product_name'] ?? json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['selling_price'] ?? json['price'] ?? 0.0).toDouble(),
      unit: json['quantity'] ?? json['volume'] ?? json['unit'] ?? '',
      imageUrl: img,
      inStock: json['stock_status'] == 1 || json['stock_status'] == 'in_stock' || (json['inStock'] ?? true),
      vendorId: vId,
      vendorShopName: json['vendor_shop_name']?.toString(),
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
      if (vendorId != null && vendorId!.isNotEmpty) 'vendor_id': vendorId,
      if (vendorShopName != null && vendorShopName!.isNotEmpty) 'vendor_shop_name': vendorShopName,
    };
  }
}
