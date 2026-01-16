import 'package:object_box_poc/models/order_model.dart';
import 'package:object_box_poc/models/user_model.dart';

/// Sealed class for representing detail screen data
/// Uses Dart 3 pattern matching for type-safe UI rendering
sealed class DetailModel {
  String get title;
  String get subtitle;
}

/// Detail model for User entities
class UserDetailModel extends DetailModel {
  final User user;

  UserDetailModel(this.user);

  @override
  String get title => '${user.name ?? ''} ${user.surname ?? ''}'.trim();

  @override
  String get subtitle => 'User ID: ${user.id}';
}

/// Detail model for Order entities
class OrderDetailModel extends DetailModel {
  final OrderModel order;

  OrderDetailModel(this.order);

  @override
  String get title => order.name ?? 'Unnamed Order';

  @override
  String get subtitle => '\$${order.amount ?? 0}';
}
