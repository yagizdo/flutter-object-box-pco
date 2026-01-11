import 'package:object_box_poc/models/address_model.dart';
import 'package:object_box_poc/models/user_model.dart';

import 'package:object_box_poc/gen/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ObjectboxManager {
  /// The store is the main entry point for the ObjectBox database
  late final Store _store;

  late final Box<User> _userBox;
  late final Box<Address> _addressBox;
  late final Box<Order> _orderBox;

  /// Private constructor to create the instance
  ObjectboxManager._create(this._store) {
    _userBox = Box<User>(_store);
    _addressBox = Box<Address>(_store);
    _orderBox = Box<Order>(_store);
  }

  /// Create the instance of the ObjectboxManager
  /// This method will create the instance of the ObjectboxManager
  static Future<ObjectboxManager> create() async {
    final docDirectory = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(docDirectory.path, 'objectbox-poc'),
    );

    return ObjectboxManager._create(store);
  }
}
