class Product {
  final int id;
  final String? name;
  final String? description;
  final double price;

  Product(this.id, this.name, this.description, this.price);

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        price = json['price'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discription': description,
      'price': price,
    };
  }
}
