import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../widgets/map_preview.dart';
import '../widgets/tag_chip.dart';
import '../utils/constants.dart';
import '../utils/date_util.dart' as du;
import 'edit_item.dart';

class ItemDetailScreen extends StatelessWidget {
  final ItemModel item;

  const ItemDetailScreen({super.key, required this.item});

  Future<void> _openInMaps(BuildContext context) async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${item.lat},${item.long}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _markBought(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Got it!'),
        content: Text('Mark "${item.name}" as bought?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, bought it!',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ItemProvider>().markAsBought(item.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteItem(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete item?'),
        content:
        Text('Remove "${item.name}" from your watchlist permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ItemProvider>().deleteItem(item);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Photo app bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditItemScreen(item: item)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: () => _deleteItem(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: item.photoPath.isNotEmpty
                  ? Image.file(File(item.photoPath), fit: BoxFit.cover)
                  : Container(
                color: AppColors.primaryLight,
                child: const Center(
                  child: Icon(Icons.storefront_outlined,
                      size: 64, color: AppColors.primary),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        du.DateUtils.formatPrice(item.price),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Days on list
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.daysOnList >= 7
                          ? const Color(0xFFFAEEDA)
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      du.DateUtils.daysAgoLabel(item.daysOnList),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: item.daysOnList >= 7
                            ? const Color(0xFF854F0B)
                            : AppColors.primaryDark,
                      ),
                    ),
                  ),

                  // Tags
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.tags
                          .map((t) => TagChip(label: t))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 20),

                  // Location section
                  const Text('Where to find it',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.locLabel,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Map
                  MapPreview(lat: item.lat, long: item.long),
                  const SizedBox(height: 10),

                  // Open in Maps button
                  OutlinedButton.icon(
                    onPressed: () => _openInMaps(context),
                    icon: const Icon(Icons.map_outlined,
                        size: 18, color: AppColors.primary),
                    label: const Text('Open in Google Maps',
                        style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(
                          color: AppColors.primary, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Bought it button
                  if (item.status == ItemStatus.watching)
                    ElevatedButton.icon(
                      onPressed: () => _markBought(context),
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text("Bought it!"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.primaryDark,
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}