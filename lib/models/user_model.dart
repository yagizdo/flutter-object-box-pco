import 'package:object_box_poc/models/address_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class User {
  @Id()
  int id = 0;

  String? name;

  // We can have multiple orders for a user
  // We use backlink annotation to define the relation from the other side
  // This is a to-many relation
  @Backlink()
  final orders = ToMany<Order>();

  // We can have one address for a user
  final address = ToOne<Address>();
}
