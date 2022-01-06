class Item {
  String? id;
  String? title;
  double? price;
  Item({
    this.id,
    this.title,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      title: map['title'],
      price: map['price']?.toDouble(),
    );
  }
}
