import 'package:object_box_poc/models/address_model.dart';
import 'package:object_box_poc/models/user_model.dart';

import 'package:object_box_poc/gen/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ObjectboxManager {
  late final Box<User> _userBox;
  late final Box<Address> _addressBox;
  late final Box<Order> _orderBox;

  static ObjectboxManager? _instance;

  Box get userBox => _userBox;
  Box get addressBox => _addressBox;
  Box get orderBox => _orderBox;

  // Private constructor to create the instance lazy loading
  ObjectboxManager._internal() {
    _initialize();
  }

  /// Lazy initialization of the instance
  void _initialize() {
    _instance ??= ObjectboxManager._internal();
  }

  /// Create the store and initialize the boxes and create directory if not exists
  static Future<void> create() async {
    final docDirectory = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(docDirectory.path, 'objectbox-poc'),
    );
    _instance?._initBoxes(store);
  }

  void _initBoxes(Store store) {
    _userBox = Box<User>(store);
    _addressBox = Box<Address>(store);
    _orderBox = Box<Order>(store);
  }
}
