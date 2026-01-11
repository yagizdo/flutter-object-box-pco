import 'package:objectbox/objectbox.dart';

@Entity()
class Address {
  @Id()
  int id = 0;

  String? street;
  String? city;
  String? state;
  String? zip;
}
