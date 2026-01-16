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
- **Interactive UI Demo**: Visual demonstration of entity relationships and data access methods

## PoC UI Demo

The application includes a fully functional UI that visually demonstrates ObjectBox concepts and relationship navigation.

### Screens

#### HomeScreen

The main screen displays all Users and Orders with:

- **Users Section**: Shows all users retrieved via `userBox.getAll()`
- **Orders Section**: Shows all orders retrieved via `orderBox.getAll()`
- **Add Data Button** (+): Adds sample users and orders
- **Clear Data Button**: Removes all entities from the database
- **Pull-to-Refresh**: Reloads data from ObjectBox

```
┌─────────────────────────────────────────┐
│  ObjectBox PoC Demo          [+] [🗑️]  │
├─────────────────────────────────────────┤
│  👥 Users                          [3]  │
│  ┌─────────────────────────────────────┐│
│  │ 📦 userBox.getAll()                ││
│  └─────────────────────────────────────┘│
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │ John D. │ │ Jane S. │ │ Jack B. │   │
│  │ 2 orders│ │ 1 order │ │ 0 orders│   │
│  └─────────┘ └─────────┘ └─────────┘   │
│                                         │
│  🛍️ Orders                         [3]  │
│  ┌─────────────────────────────────────┐│
│  │ 📦 orderBox.getAll()               ││
│  └─────────────────────────────────────┘│
│  ┌─────────────────────────────────┐   │
│  │ Order 1 - $250    → John Doe    │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

#### DetailScreen

A shared detail screen that uses Dart 3 sealed classes and pattern matching to display either User or Order details.

**User Details show:**
- User information (name, ID)
- Address via `user.address.target` (ToOne relationship)
- Orders via `user.orders` (ToMany Backlink)

**Order Details show:**
- Order information (name, amount, ID)
- Customer via `order.user.target` (ToOne relationship)

Each relationship section includes a `MethodInfoBox` displaying the ObjectBox code used to access the data.

### Sealed Class Pattern

The `DetailModel` sealed class enables type-safe navigation and pattern matching:

```dart
sealed class DetailModel {
  String get title;
  String get subtitle;
}

class UserDetailModel extends DetailModel { ... }
class OrderDetailModel extends DetailModel { ... }

// Usage in DetailScreen
switch (model) {
  UserDetailModel(user: final user) => _buildUserDetails(user),
  OrderDetailModel(order: final order) => _buildOrderDetails(order),
}
```

### Visual Relationship Demonstration

The UI demonstrates how ObjectBox relationships work:

| Relationship | Access Method | UI Display |
|--------------|---------------|------------|
| User → Address | `user.address.target` | Address card in user details |
| User → Orders | `user.orders` (Backlink) | List of order cards |
| Order → User | `order.user.target` | User card in order details |

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
│   ├── address_model.dart                   # Address entity
│   └── detail_model.dart                    # Sealed class for detail screen
├── screens/
│   ├── home_screen.dart                     # Main screen with entity lists
│   └── detail_screen.dart                   # Shared detail screen
├── widgets/
│   ├── entity_list_card.dart                # Reusable list card widget
│   ├── method_info_box.dart                 # Code snippet display widget
│   └── relationship_card.dart               # Relationship visualization
└── main.dart                                # App entry point with theming
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

### Data Access Methods

The manager provides convenient methods for UI consumption:

```dart
// Get all entities
List<User> users = ObjectboxManager.instance.getUsers();
List<OrderModel> orders = ObjectboxManager.instance.getOrders();

// Get by ID
User? user = ObjectboxManager.instance.getUserById(1);
OrderModel? order = ObjectboxManager.instance.getOrderById(1);
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

## Reusable Widgets

The UI is built with reusable, customizable widgets:

### EntityListCard

A card widget for displaying entities in lists with icon, title, subtitle, and optional trailing info.

```dart
EntityListCard(
  title: 'John Doe',
  subtitle: 'ID: 1',
  trailing: '2 orders',
  icon: Icons.person,
  onTap: () => navigateToDetail(user),
)
```

### MethodInfoBox

Displays ObjectBox method names with optional code snippets and syntax highlighting.

```dart
MethodInfoBox(
  methodName: 'user.orders',
  description: 'ToMany relationship with Backlink',
  codeSnippet: 'for (var order in user.orders) { ... }',
)
```

### RelationshipCard

Visualizes entity relationships with relationship type badges and method code display.

```dart
RelationshipCard(
  title: 'Orders',
  relationshipType: 'ToMany (Backlink)',
  methodCode: 'user.orders',
  icon: Icons.shopping_bag,
  child: OrdersList(orders: user.orders),
)
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
