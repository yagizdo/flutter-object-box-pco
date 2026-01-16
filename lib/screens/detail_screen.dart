import 'package:flutter/material.dart';
import 'package:object_box_poc/core/cache/manager/objectbox_manager.dart';
import 'package:object_box_poc/models/address_model.dart';
import 'package:object_box_poc/models/detail_model.dart';
import 'package:object_box_poc/models/order_model.dart';
import 'package:object_box_poc/models/user_model.dart';
import 'package:object_box_poc/widgets/method_info_box.dart';
import 'package:object_box_poc/widgets/relationship_card.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.model});

  final DetailModel model;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ObjectboxManager _manager = ObjectboxManager.instance;

  User? _user;
  OrderModel? _order;

  @override
  void initState() {
    super.initState();
    _resolveLatest();
  }

  void _resolveLatest() {
    switch (widget.model) {
      case UserDetailModel(:final user):
        _user = _manager.getUserById(user.id);
        _order = null;
      case OrderDetailModel(:final order):
        _order = _manager.getOrderById(order.id);
        _user = null;
    }
    setState(() {});
  }

  void _open(DetailModel model) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DetailScreen(model: model)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = switch (widget.model) {
      UserDetailModel() => _buildUserDetail(theme),
      OrderDetailModel() => _buildOrderDetail(theme),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model.appBarTitle),
        actions: [
          IconButton(
            tooltip: 'Reload from DB',
            onPressed: _resolveLatest,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(12), children: content),
      ),
    );
  }

  List<Widget> _buildUserDetail(ThemeData theme) {
    final model = widget.model as UserDetailModel;
    final user = _user ?? model.user;
    final address = user.address.target;
    final orders = user.orders;

    return [
      Card(
        child: ListTile(
          title: Text(
            '${user.name ?? '-'} ${user.surname ?? ''}'.trim(),
            style: theme.textTheme.titleLarge,
          ),
          subtitle: Text('User #${user.id}'),
        ),
      ),
      const SizedBox(height: 12),
      MethodInfoBox(
        methodLabel: 'Loaded via',
        code: 'final user = manager.getUserById(${user.id});',
        description:
            'The detail screen reloads the latest entity from ObjectBox by ID to make the used access method explicit.',
      ),
      const SizedBox(height: 12),
      RelationshipCard(
        title: 'Address (ToOne)',
        methodLabel: 'user.address.target',
        code: 'final address = user.address.target;',
        description:
            'Reads the optional ToOne relation. In this PoC, some users intentionally have no address.',
        child: _AddressView(address: address),
      ),
      const SizedBox(height: 12),
      RelationshipCard(
        title: 'Orders (Backlink / ToMany)',
        methodLabel: 'user.orders',
        code: 'for (final order in user.orders) {\n  // ...\n}',
        description:
            'Uses @Backlink to resolve the User → Orders relationship from the inverse side.',
        child: orders.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No orders for this user.'),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final amount = order.amount == null ? '—' : '${order.amount}';

                  return ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(order.name ?? 'Order #${order.id}'),
                    subtitle: Text('Order #${order.id} • amount: $amount'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(OrderDetailModel(order)),
                  );
                },
              ),
      ),
    ];
  }

  List<Widget> _buildOrderDetail(ThemeData theme) {
    final model = widget.model as OrderDetailModel;
    final order = _order ?? model.order;
    final user = order.user.target;

    final amount = order.amount == null ? '—' : '${order.amount}';

    return [
      Card(
        child: ListTile(
          leading: const Icon(Icons.receipt_long_outlined),
          title: Text(order.name ?? 'Order #${order.id}'),
          subtitle: Text('Order #${order.id} • amount: $amount'),
        ),
      ),
      const SizedBox(height: 12),
      MethodInfoBox(
        methodLabel: 'Loaded via',
        code: 'final order = manager.getOrderById(${order.id});',
        description:
            'The detail screen reloads the latest entity from ObjectBox by ID to make the used access method explicit.',
      ),
      const SizedBox(height: 12),
      RelationshipCard(
        title: 'User (ToOne)',
        methodLabel: 'order.user.target',
        code: 'final user = order.user.target;',
        description:
            'Reads the ToOne relation from Order → User and allows navigation to the same shared detail screen.',
        child: user == null
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No user linked to this order.'),
              )
            : ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text('${user.name ?? '-'} ${user.surname ?? ''}'.trim()),
                subtitle: Text('User #${user.id}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(UserDetailModel(user)),
              ),
      ),
    ];
  }
}

class _AddressView extends StatelessWidget {
  const _AddressView({required this.address});

  final Address? address;

  @override
  Widget build(BuildContext context) {
    final a = address;
    if (a == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No address linked.'),
      );
    }

    final parts = <String>[
      if (a.street?.isNotEmpty ?? false) a.street!,
      if (a.city?.isNotEmpty ?? false) a.city!,
      if (a.state?.isNotEmpty ?? false) a.state!,
      if (a.zip?.isNotEmpty ?? false) a.zip!,
    ];

    return ListTile(
      leading: const Icon(Icons.location_on_outlined),
      title: Text(parts.isEmpty ? 'Address #${a.id}' : parts.join(', ')),
      subtitle: Text('Address #${a.id}'),
    );
  }
}
