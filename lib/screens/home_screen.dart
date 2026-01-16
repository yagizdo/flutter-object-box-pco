import 'package:flutter/material.dart';
import 'package:object_box_poc/core/cache/manager/objectbox_manager.dart';
import 'package:object_box_poc/models/detail_model.dart';
import 'package:object_box_poc/models/order_model.dart';
import 'package:object_box_poc/models/user_model.dart';
import 'package:object_box_poc/screens/detail_screen.dart';
import 'package:object_box_poc/widgets/entity_list_card.dart';
import 'package:object_box_poc/widgets/method_info_box.dart';

/// Main screen displaying Users and Orders from ObjectBox
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> _users = [];
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _users = ObjectboxManager.instance.getUsers();
      _orders = ObjectboxManager.instance.getOrders();
    });
  }

  void _addSampleData() {
    ObjectboxManager.instance.save();
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample data added'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to delete all data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ObjectboxManager.instance.removeAll();
              _loadData();
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToUserDetail(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(model: UserDetailModel(user)),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToOrderDetail(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(model: OrderDetailModel(order)),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ObjectBox PoC Demo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Sample Data',
            onPressed: _addSampleData,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear All Data',
            onPressed: _clearAllData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Users Section
              _buildSectionHeader(
                context,
                icon: Icons.people,
                title: 'Users',
                count: _users.length,
              ),
              const MethodInfoBox(
                methodName: 'userBox.getAll()',
                description: 'Retrieves all User entities from the ObjectBox database',
              ),
              if (_users.isEmpty)
                _buildEmptyState(
                  context,
                  icon: Icons.person_off,
                  message: 'No users found. Tap + to add sample data.',
                )
              else
                ..._users.map(
                  (user) => EntityListCard(
                    title: '${user.name ?? ''} ${user.surname ?? ''}'.trim(),
                    subtitle: 'ID: ${user.id}',
                    trailing: '${user.orders.length} orders',
                    icon: Icons.person,
                    iconColor: theme.colorScheme.primary,
                    onTap: () => _navigateToUserDetail(user),
                  ),
                ),

              const SizedBox(height: 24),

              // Orders Section
              _buildSectionHeader(
                context,
                icon: Icons.shopping_bag,
                title: 'Orders',
                count: _orders.length,
              ),
              const MethodInfoBox(
                methodName: 'orderBox.getAll()',
                description: 'Retrieves all Order entities from the ObjectBox database',
              ),
              if (_orders.isEmpty)
                _buildEmptyState(
                  context,
                  icon: Icons.shopping_cart_outlined,
                  message: 'No orders found. Tap + to add sample data.',
                )
              else
                ..._orders.map(
                  (order) => EntityListCard(
                    title: order.name ?? 'Unnamed Order',
                    subtitle: order.user.target != null
                        ? '${order.user.target!.name} ${order.user.target!.surname}'
                        : 'No user assigned',
                    trailing: '\$${order.amount ?? 0}',
                    icon: Icons.receipt_long,
                    iconColor: theme.colorScheme.tertiary,
                    onTap: () => _navigateToOrderDetail(order),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
