# ObjectBox Flutter POC

A proof-of-concept Flutter application demonstrating ObjectBox database integration with entity relationships, singleton manager pattern, and CRUD operations.

## Overview

This project showcases how to implement a local NoSQL database using [ObjectBox](https://objectbox.io/) in Flutter. It demonstrates:

- Entity definitions with annotations
- One-to-One and One-to-Many relationships
- Backlink references for bidirectional access
- Singleton manager pattern for database operations
- Full CRUD (Create, Read, Update, Delete) operations

## Features

- **High-Performance Local Database**: ObjectBox provides fast, ACID-compliant database operations
- **Entity Relationships**: Demonstrates `ToOne` and `ToMany` relations between entities
- **Singleton Pattern**: Centralized database manager for consistent access across the app
- **Type-Safe Queries**: Leverages ObjectBox's generated code for compile-time safety

## Project Structure

```
lib/
├── core/
│   └── cache/
│       ├── abstract/
│       │   └── i_objectbox_manager.dart    # Manager interface
│       └── manager/
│           └── objectbox_manager.dart       # Singleton implementation
├── gen/
│   ├── objectbox-model.json                 # Generated model schema
│   └── objectbox.g.dart                     # Generated ObjectBox code
├── models/
│   ├── user_model.dart                      # User entity
│   ├── order_model.dart                     # Order entity
│   └── address_model.dart                   # Address entity
└── main.dart                                # App entry point
```

## Entity Models

### User

```dart
@Entity()
class User {
  @Id()
  int id = 0;

  String? name;
  String? surname;

  @Backlink()
  final orders = ToMany<OrderModel>();  // One-to-Many relationship

  final address = ToOne<Address>();      // One-to-One relationship
}
```

### Order

```dart
@Entity()
class OrderModel {
  @Id()
  int id = 0;

  String? name;
  int? amount;

  final user = ToOne<User>();  // Many-to-One relationship
}
```

### Address

```dart
@Entity()
class Address {
  @Id()
  int id = 0;

  String? street;
  String? city;
  String? state;
  String? zip;
}
```

## Relationships Diagram

```
┌─────────────────┐         ┌─────────────────┐
│      User       │         │     Address     │
├─────────────────┤         ├─────────────────┤
│ id              │    1:1  │ id              │
│ name            │────────►│ street          │
│ surname         │         │ city            │
│ address (ToOne) │         │ state           │
│ orders (ToMany) │         │ zip             │
└────────┬────────┘         └─────────────────┘
         │
         │ 1:N (Backlink)
         ▼
┌─────────────────┐
│   OrderModel    │
├─────────────────┤
│ id              │
│ name            │
│ amount          │
│ user (ToOne)    │
└─────────────────┘
```

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.4
- Dart SDK ^3.10.4

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/object_box_poc.git
   cd object_box_poc
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate ObjectBox code (if needed):
   ```bash
   dart run build_runner build
   ```

4. Run the application:
   ```bash
   flutter run
   ```

## Usage

### Initializing the Database

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load ObjectBox library for Android 6 compatibility
  loadObjectBoxLibraryAndroidCompat();
  
  // Initialize the singleton manager
  await ObjectboxManager.instance.create();
  
  runApp(const MainApp());
}
```

### CRUD Operations

#### Create (Save)
```dart
ObjectboxManager.instance.save();
```

#### Read (Get All)
```dart
ObjectboxManager.instance.get();
```

#### Update
```dart
ObjectboxManager.instance.update(userId, 'New Name');
```

#### Delete Single
```dart
ObjectboxManager.instance.delete(userId);
```

#### Delete All
```dart
ObjectboxManager.instance.removeAll();
```

### Accessing Boxes Directly

```dart
final userBox = ObjectboxManager.instance.userBox;
final orderBox = ObjectboxManager.instance.orderBox;
final addressBox = ObjectboxManager.instance.addressBox;

// Custom queries
final users = userBox.getAll();
final specificUser = userBox.get(1);
```

## Key Concepts

### Singleton Manager Pattern

The `ObjectboxManager` uses a singleton pattern to ensure a single database instance throughout the app:

```dart
static ObjectboxManager get instance => _instance ??= ObjectboxManager._();
```

### ToOne Relationship

Used for one-to-one or many-to-one relationships:

```dart
final address = ToOne<Address>();  // User has one address
final user = ToOne<User>();        // Order belongs to one user
```

### ToMany with Backlink

Used for one-to-many relationships with bidirectional access:

```dart
// In User: access all orders for this user
@Backlink()
final orders = ToMany<OrderModel>();

// In OrderModel: reference back to the user
final user = ToOne<User>();
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `objectbox` | ^5.1.0 | Core ObjectBox database |
| `objectbox_flutter_libs` | any | Native platform libraries |
| `path_provider` | ^2.1.5 | App directory access |
| `path` | ^1.9.1 | Path manipulation |
| `objectbox_generator` | any | Code generation (dev) |
| `build_runner` | ^2.10.4 | Build system (dev) |

## Configuration

ObjectBox is configured to output generated files to a custom directory:

```yaml
# pubspec.yaml
objectbox:
  output_dir: gen
```

This generates `objectbox-model.json` and `objectbox.g.dart` in `lib/gen/`.

## Additional Resources

- [ObjectBox Documentation](https://docs.objectbox.io/getting-started)
- [ObjectBox Dart/Flutter](https://github.com/objectbox/objectbox-dart)
- [Factory Pattern Guide](docs/factory_pattern_guide.md) - Advanced manager patterns

## License

This project is for educational and proof-of-concept purposes.
