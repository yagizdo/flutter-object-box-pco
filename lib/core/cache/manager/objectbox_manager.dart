import 'package:object_box_poc/core/cache/abstract/i_objectbox_manager.dart';
import 'package:object_box_poc/models/address_model.dart';
import 'package:object_box_poc/models/user_model.dart';

import 'package:object_box_poc/gen/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Why this class is singleton?
/// Because we need to access the same instance of the ObjectboxManager in the whole app
///

class ObjectboxManager {
  late final Store _store;

  late final Box<User> _userBox;
  late final Box<Address> _addressBox;
  late final Box<Order> _orderBox;

  static ObjectboxManager? _instance;

  // Getters
  Box<User> get userBox => _userBox;
  Box<Address> get addressBox => _addressBox;
  Box<Order> get orderBox => _orderBox;

  static ObjectboxManager get instance => _instance ??= ObjectboxManager._();

  ObjectboxManager._();

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
    _orderBox = _store.box<Order>();
  }

  void close() {
    _store.close();
  }
}
