import 'dart:math';

import 'package:object_box_poc/core/cache/abstract/i_objectbox_manager.dart';
import 'package:object_box_poc/models/address_model.dart';
import 'package:object_box_poc/models/order_model.dart';
import 'package:object_box_poc/models/user_model.dart';

import 'package:object_box_poc/gen/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Why this class is singleton?
/// Because we need to access the same instance of the ObjectboxManager in the whole app
///

class ObjectboxManager implements IObjectboxManager {
  late final Store _store;

  late final Box<User> _userBox;
  late final Box<Address> _addressBox;
  late final Box<OrderModel> _orderBox;

  static ObjectboxManager? _instance;

  // Getters
  Box<User> get userBox => _userBox;
  Box<Address> get addressBox => _addressBox;
  Box<OrderModel> get orderBox => _orderBox;

  static ObjectboxManager get instance => _instance ??= ObjectboxManager._();

  ObjectboxManager._();

  // ---------- UI-friendly read methods (used by the PoC screens) ----------
  List<User> getUsers() => _userBox.getAll();
  List<OrderModel> getOrders() => _orderBox.getAll();
  User? getUserById(int id) => _userBox.get(id);
  OrderModel? getOrderById(int id) => _orderBox.get(id);

  @override
  Future<void> create() async {
    final docDirectory = await getApplicationDocumentsDirectory();
    _store = await openStore(
      directory: p.join(docDirectory.path, 'objectbox-poc'),
    );
    _initBoxes();
  }

  void _initBoxes() {
    _userBox = _store.box<User>();
    _addressBox = _store.box<Address>();
    _orderBox = _store.box<OrderModel>();
  }

  OrderModel _createOrder({required User user}) {
    final order = OrderModel();
    order.name = 'Order ${Random().nextInt(10)}';
    order.amount = Random().nextInt(1000);
    order.user.target = user;

    return order;
  }

  User _createUser() {
    final user = User();
    user.name = _generateRandomFullName().$1;
    user.surname = _generateRandomFullName().$2;
    return user;
  }

  Address _createAddress() {
    final streets = [
      'Main St',
      'Oak Ave',
      'Pine Rd',
      'Maple Dr',
      'Cedar Ln',
    ];
    final cities = [
      'Springfield',
      'Riverside',
      'Fairview',
      'Madison',
      'Georgetown',
    ];
    final states = ['CA', 'NY', 'TX', 'FL', 'WA'];

    final address = Address();
    address.street = '${100 + Random().nextInt(900)} ${streets[Random().nextInt(streets.length)]}';
    address.city = cities[Random().nextInt(cities.length)];
    address.state = states[Random().nextInt(states.length)];
    address.zip = '${10000 + Random().nextInt(89999)}';
    return address;
  }

  (String, String) _generateRandomFullName() {
    final names = [
      'John',
      'Jane',
      'Jim',
      'Jill',
      'Jack',
      'Jill',
      'Jill',
      'Jill',
      'Jill',
      'Jill',
    ];
    final surnames = [
      'Doe',
      'Smith',
      'Johnson',
      'Williams',
      'Brown',
      'Jones',
      'Garcia',
      'Miller',
      'Davis',
      'Rodriguez',
    ];
    return (
      names[Random().nextInt(names.length)],
      surnames[Random().nextInt(surnames.length)],
    );
  }

  @override
  bool save() {
    // Persist Users (and their Address) first so relations are stable.
    final users = <User>[
      _createUser(),
      _createUser(),
      _createUser(),
    ];

    for (var i = 0; i < users.length; i++) {
      // Keep one user without address to demonstrate optional relations.
      if (i == users.length - 1) continue;
      final address = _createAddress();
      _addressBox.put(address);
      users[i].address.target = address;
    }

    final userIds = _userBox.putMany(users);

    // Now create Orders referencing persisted Users.
    final orders = <OrderModel>[];
    for (final user in users) {
      final orderCount = 1 + Random().nextInt(3);
      for (var i = 0; i < orderCount; i++) {
        orders.add(_createOrder(user: user));
      }
    }

    final orderIds = _orderBox.putMany(orders);

    if (userIds.isNotEmpty && orderIds.isNotEmpty) {
      print('Saved User IDs: $userIds');
      print('Saved Order IDs: $orderIds');
      return true;
    }
    print('Failed to save users and orders');
    return false;
  }

  @override
  void get() {
    _getOrders();
    _getUsers();
  }

  void _getUsers() {
    final users = _userBox.getAll();
    for (var user in users) {
      print(' ---------- USERS ----------');
      print('----------------------------');
      print('User id: ${user.id}');
      print('User Name: ${user.name}');
      print('User Surname: ${user.surname}');
      print('User Orders: ${user.orders.length}');
      print('');

      // We can access the orders of the user
      for (var order in user.orders) {
        print('');
        print(' ---------- ${user.id} ID USER ORDERS ----------');
        print('----------------------------');
        print('User Order id: ${order.id}');
        print('User Order Name: ${order.name}');
        print('User Order Amount: ${order.amount}');
        print('User Order User: ${order.user}');
        print('User Order User Name: ${order.user.target?.name}');
      }
    }
  }

  void _getOrders() {
    final orders = _orderBox.getAll();
    print(' ---------- ALL ORDERS ----------');
    print('----------------------------');
    for (var order in orders) {
      print('Order id: ${order.id}');
      print('Order Name: ${order.name}');
      print('Order Amount: ${order.amount}');
      print('Order User: ${order.user}');
      print('Order User Name: ${order.user.target?.name}');
      print('');
    }
  }

  @override
  bool update(int userID, String updatedUserName) {
    User? user = _userBox.get(userID);
    if (user != null) {
      final oldName = user.name;
      user.name = updatedUserName;
      _userBox.put(user);
      print('User updated: $oldName -> ${user.name}');
      return true;
    }
    return false;
  }

  @override
  void removeAll() {
    _userBox.removeAll();
    _orderBox.removeAll();
    _addressBox.removeAll();
    print('All data removed');
  }

  @override
  bool delete(int userID) {
    final user = _userBox.get(userID);
    if (user != null) {
      _userBox.remove(user.id);
      return true;
    }
    return false;
  }

  @override
  void close() {
    _store.close();
  }
}
