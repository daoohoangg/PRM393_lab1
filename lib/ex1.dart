import 'dart:async';

class Product {
  final int id;
  final String name;
  final double price;

  Product(this.id, this.name, this.price);

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}

class ProductRepository {
  final List<Product> _products = [
    Product(1, 'Keyboard', 49.9),
    Product(2, 'Mouse', 19.5),
  ];

  final StreamController<Product> _controller =
  StreamController<Product>.broadcast();

  Future<List<Product>> getAll() async {
    await Future.delayed(Duration(milliseconds: 200));
    return _products;
  }

  Stream<Product> liveAdded() => _controller.stream;

  void add(Product p) {
    _products.add(p);
    _controller.add(p);
  }
}

Future<void> main() async {
  final repo = ProductRepository();

  // Listen to stream updates
  repo.liveAdded().listen((p) {
    print('[STREAM] Added: $p');
  });

  final products = await repo.getAll();
  print('[FUTURE] Initial products:');
  products.forEach(print);

  repo.add(Product(3, 'Monitor', 150));
}
