import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/tag_chip.dart';
import '../utils/constants.dart';
import 'add_item.dart';
import 'item_detail.dart';
import 'archive.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().listenToItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final items = provider.watchingItems;
    final tags = provider.allTags;
    final selectedTag = provider.filterTag;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thrifthem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Bought archive',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ArchiveScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag filter chips
          if (tags.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tags.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => TagChip(
                  label: tags[i],
                  selected: selectedTag == tags[i],
                  onTap: () => provider.setFilter(tags[i]),
                ),
              ),
            ),

          if (tags.isNotEmpty) const SizedBox(height: 8),

          // Item grid
          Expanded(
            child: items.isEmpty
                ? _EmptyState()
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => ItemCard(
                item: items[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ItemDetailScreen(item: items[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Find'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.storefront_outlined,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'No finds yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Spot something at a thrift market?\nTap + Add Find to save it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}