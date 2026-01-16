import 'package:flutter/material.dart';
import 'package:object_box_poc/core/cache/manager/objectbox_manager.dart';
import 'package:object_box_poc/models/detail_model.dart';
import 'package:object_box_poc/models/order_model.dart';
import 'package:object_box_poc/models/user_model.dart';
import 'package:object_box_poc/screens/detail_screen.dart';
import 'package:object_box_poc/widgets/entity_list_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ObjectboxManager _manager = ObjectboxManager.instance;

  List<User> _users = const [];
  List<OrderModel> _orders = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _users = _manager.getUsers();
      _orders = _manager.getOrders();
    });
  }

  void _seedData() {
    _manager.save();
    _reload();
  }

  void _clearAll() {
    _manager.removeAll();
    _reload();
  }

  void _openDetail(DetailModel model) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DetailScreen(model: model)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ObjectBox PoC Demo'),
        actions: [
          IconButton(
            tooltip: 'Seed demo data (manager.save())',
            onPressed: _seedData,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: 'Clear all (manager.removeAll())',
            onPressed: _clearAll,
            icon: const Icon(Icons.delete_outline),
          ),
          IconButton(
            tooltip: 'Refresh lists',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            EntityListCard(
              title: 'Users',
              methodLabel: 'manager.getUsers()',
              child: _users.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No users yet. Tap + to seed demo data.'),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        final fullName =
                            '${user.name ?? '-'} ${user.surname ?? ''}'.trim();
                        final initials = (user.name?.isNotEmpty ?? false)
                            ? user.name!.substring(0, 1).toUpperCase()
                            : '?';

                        return ListTile(
                          leading: CircleAvatar(child: Text(initials)),
                          title: Text(fullName),
                          subtitle: Text(
                            'User #${user.id} • orders: ${user.orders.length} • address: ${user.address.target == null ? '—' : '✓'}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDetail(UserDetailModel(user)),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            EntityListCard(
              title: 'Orders',
              methodLabel: 'manager.getOrders()',
              child: _orders.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No orders yet. Tap + to seed demo data.'),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final userName = order.user.target == null
                            ? '—'
                            : '${order.user.target?.name ?? '-'} ${order.user.target?.surname ?? ''}'
                                  .trim();
                        final amount = order.amount == null
                            ? '—'
                            : '${order.amount}';

                        return ListTile(
                          leading: const Icon(Icons.receipt_long_outlined),
                          title: Text(order.name ?? 'Order #${order.id}'),
                          subtitle: Text(
                            'Order #${order.id} • amount: $amount • user: $userName',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDetail(OrderDetailModel(order)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
