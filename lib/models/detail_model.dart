import 'package:object_box_poc/models/order_model.dart';
import 'package:object_box_poc/models/user_model.dart';

sealed class DetailModel {
  const DetailModel();

  String get appBarTitle;
  String get title;
  String? get subtitle;
}

final class UserDetailModel extends DetailModel {
  const UserDetailModel(this.user);

  final User user;

  @override
  String get appBarTitle => 'User Details';

  @override
  String get title => '${user.name ?? '-'} ${user.surname ?? ''}'.trim();

  @override
  String? get subtitle => 'User #${user.id}';
}

final class OrderDetailModel extends DetailModel {
  const OrderDetailModel(this.order);

  final OrderModel order;

  @override
  String get appBarTitle => 'Order Details';

  @override
  String get title => order.name ?? 'Order #${order.id}';

  @override
  String? get subtitle => order.amount == null ? null : 'Amount: ${order.amount}';
}

