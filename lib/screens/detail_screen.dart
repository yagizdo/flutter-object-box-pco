import 'package:flutter/material.dart';
import 'package:object_box_poc/models/detail_model.dart';
import 'package:object_box_poc/widgets/method_info_box.dart';
import 'package:object_box_poc/widgets/relationship_card.dart';

/// Shared detail screen that uses pattern matching on DetailModel
/// to display either User or Order details
class DetailScreen extends StatelessWidget {
  final DetailModel model;

  const DetailScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (model) {
            UserDetailModel() => 'User Details',
            OrderDetailModel() => 'Order Details',
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Entity Info Card
            _buildInfoCard(context),

            const SizedBox(height: 16),

            // Pattern matching for specific content
            switch (model) {
              UserDetailModel(user: final user) => _buildUserDetails(context, user),
              OrderDetailModel(order: final order) => _buildOrderDetails(context, order),
            },

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              switch (model) {
                UserDetailModel() => Icons.person,
                OrderDetailModel() => Icons.receipt_long,
              },
              size: 32,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  model.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context, user) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address Section
        RelationshipCard(
          title: 'Address',
          relationshipType: 'ToOne',
          methodCode: 'user.address.target',
          icon: Icons.location_on,
          child: user.address.target != null
              ? _buildAddressInfo(context, user.address.target!)
              : _buildNoDataPlaceholder(context, 'No address linked'),
        ),

        const MethodInfoBox(
          methodName: 'user.address.target',
          description:
              'ToOne<Address> relationship. Access the linked Address entity directly.',
          codeSnippet: '''final address = user.address.target;
if (address != null) {
  print(address.street);
}''',
        ),

        const SizedBox(height: 16),

        // Orders Section
        RelationshipCard(
          title: 'Orders',
          relationshipType: 'ToMany (Backlink)',
          methodCode: 'user.orders',
          icon: Icons.shopping_bag,
          child: user.orders.isNotEmpty
              ? _buildOrdersList(context, user.orders)
              : _buildNoDataPlaceholder(context, 'No orders found'),
        ),

        const MethodInfoBox(
          methodName: 'user.orders (Backlink)',
          description:
              'ToMany<OrderModel> with @Backlink annotation. Automatically populated from orders that reference this user.',
          codeSnippet: '''@Backlink()
final orders = ToMany<OrderModel>();

// Access all orders for this user
for (var order in user.orders) {
  print(order.name);
}''',
        ),
      ],
    );
  }

  Widget _buildOrderDetails(BuildContext context, order) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Info
        _buildOrderInfoSection(context, order),

        const SizedBox(height: 16),

        // User Relationship
        RelationshipCard(
          title: 'Customer',
          relationshipType: 'ToOne',
          methodCode: 'order.user.target',
          icon: Icons.person,
          child: order.user.target != null
              ? _buildUserInfo(context, order.user.target!)
              : _buildNoDataPlaceholder(context, 'No user linked'),
        ),

        const MethodInfoBox(
          methodName: 'order.user.target',
          description:
              'ToOne<User> relationship. Each order belongs to exactly one user.',
          codeSnippet: '''final user = order.user.target;
if (user != null) {
  print('\${user.name} \${user.surname}');
}''',
        ),
      ],
    );
  }

  Widget _buildAddressInfo(BuildContext context, address) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.home,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.street ?? 'No street',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '${address.city ?? ''}, ${address.state ?? ''} ${address.zip ?? ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, orders) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (final order in orders)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt,
                    size: 20,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.name ?? 'Unnamed Order',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'ID: ${order.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${order.amount ?? 0}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, user) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              (user.name ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.name ?? ''} ${user.surname ?? ''}'.trim(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'User ID: ${user.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${user.orders.length} orders',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection(BuildContext context, order) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, 'Order ID', '${order.id}'),
          const Divider(height: 24),
          _buildInfoRow(context, 'Order Name', order.name ?? 'N/A'),
          const Divider(height: 24),
          _buildInfoRow(context, 'Amount', '\$${order.amount ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataPlaceholder(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
