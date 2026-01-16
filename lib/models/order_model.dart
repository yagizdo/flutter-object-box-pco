import 'package:object_box_poc/models/user_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class OrderModel {
  @Id()
  int id = 0;

  String? name;
  int? amount;

  // We can have one specific user for an order
  // For example, a user can have multiple orders, but an order can only have one user
  // Or two users cane have same order but order id is different for each order
  // So we need to have a to-one relation here
  // This is a to-one relation
  final user = ToOne<User>();
}
