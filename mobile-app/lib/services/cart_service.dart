import 'package:flutter/foundation.dart';

class CartItem {
  final String drugId;
  final String name;
  final double price;
  final String warehouseId;
  int quantity;

  CartItem({
    required this.drugId,
    required this.name,
    required this.price,
    required this.warehouseId,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.total);

  void addItem(Map<String, dynamic> drug, {int quantity = 1}) {
    final newItemWarehouseId = drug['warehouse']['_id'] ?? drug['warehouse'];
    
    // Prevent mixing warehouses
    if (_items.isNotEmpty && _items.first.warehouseId != newItemWarehouseId) {
      throw Exception('لا يمكنك إضافة أدوية من مستودعات مختلفة في طلب واحد. يرجى الشراء من هذا المستودع أولاً، أو إفراغ السلة.');
    }

    // Check if item already exists
    final index = _items.indexWhere((item) => item.drugId == drug['_id']);
    
    if (index >= 0) {
      if (quantity > 1) {
        _items[index].quantity = quantity; // Overwrite if bulk add
      } else {
        _items[index].quantity++; // Default increment
      }
    } else {
      _items.add(CartItem(
        drugId: drug['_id'],
        name: drug['name'],
        price: (drug['price'] as num).toDouble(),
        warehouseId: newItemWarehouseId, 
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void removeItem(String drugId) {
    _items.removeWhere((item) => item.drugId == drugId);
    notifyListeners();
  }

  void updateQuantity(String drugId, int quantity) {
    final index = _items.indexWhere((item) => item.drugId == drugId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
  
  // Group items by warehouse (since backend might require separate orders per warehouse, 
  // or we can handle it. For now, let's assume one order can have multiple items, 
  // but the backend createOrder expects a single warehouse per order? 
  // Let's check the backend controller again. 
  // Yes, createOrder takes "warehouse" ID in body. So we can only order from one warehouse at a time 
  // OR we need to split orders. 
  // For MVP simplicity: We will assume all drugs are from the same warehouse OR 
  // we will just pick the warehouse of the first item and warn/filter?
  // Let's implement a helper to get the primary warehouse ID.
  String? get currentWarehouseId {
    if (_items.isEmpty) return null;
    return _items.first.warehouseId;
  }
}
