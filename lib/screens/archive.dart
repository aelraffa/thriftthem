import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/item_provider.dart';
import '../utils/constants.dart';
import '../utils/date_util.dart' as du;

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ItemProvider>().boughtItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Bought Archive')),
      body: items.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check_circle_outline,
                  size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text('No purchases yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Items you buy will show up here.',
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = items[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: item.photoPath.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: item.photoPath,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.storefront_outlined,
                        color: AppColors.primary),
                  ),
                ),
              ),
              title: Text(item.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(du.DateUtils.formatPrice(item.price),
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    item.boughtAt != null
                        ? 'Bought ${du.DateUtils.formatDate(item.boughtAt!)}'
                        : item.locLabel,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Bought',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          );
        },
      ),
    );
  }
}