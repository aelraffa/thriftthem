import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class ItemProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();

  List<ItemModel> _items = [];
  String _filterTag = '';
  bool _isLoading = false;
  String? _error;

  List<ItemModel> get watchingItems => _items
      .where((i) =>
  i.status == ItemStatus.watching &&
      (_filterTag.isEmpty || i.tags.contains(_filterTag)))
      .toList();

  List<ItemModel> get boughtItems =>
      _items.where((i) => i.status == ItemStatus.bought).toList();

  List<String> get allTags =>
      _items.expand((i) => i.tags).toSet().toList()..sort();

  String get filterTag => _filterTag;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToItems() {
    _firestore.watchItems().listen((items) {
      _items = items;
      notifyListeners();
      _notifications.checkAndNotifyStaleItems(items);
    });
  }

  void setFilter(String tag) {
    _filterTag = _filterTag == tag ? '' : tag;
    notifyListeners();
  }

  Future<void> addItem({
    required String name,
    required int price,
    required File imageFile,
    required double lat,
    required double long,
    required String locLabel,
    required List<String> tags,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = const Uuid().v4();
      // Save photo locally, store local path
      final photoPath = await _storage.saveItemPhoto(imageFile, id);

      final item = ItemModel(
        id: id,
        name: name,
        price: price,
        photoPath: photoPath,
        lat: lat,
        long: long,
        locLabel: locLabel,
        tags: tags,
        status: ItemStatus.watching,
        createdAt: DateTime.now(),
      );

      await _firestore.addItem(item);
    } catch (e) {
      _error = e.toString();
      debugPrint('addItem error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateItem({
    required ItemModel existing,
    required String name,
    required int price,
    File? newImageFile,
    required double lat,
    required double long,
    required String locLabel,
    required List<String> tags,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String photoPath = existing.photoPath;
      if (newImageFile != null) {
        photoPath = await _storage.saveItemPhoto(newImageFile, existing.id);
      }

      final updated = existing.copyWith(
        name: name,
        price: price,
        photoPath: photoPath,
        lat: lat,
        long: long,
        locLabel: locLabel,
        tags: tags,
      );

      await _firestore.updateItem(updated);
    } catch (e) {
      _error = e.toString();
      debugPrint('updateItem error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem(ItemModel item) async {
    try {
      await _firestore.deleteItem(item.id);
      await _storage.deleteItemPhoto(item.id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsBought(String itemId) async {
    try {
      await _firestore.markAsBought(itemId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> testNotification() async {
    if (_items.isNotEmpty) {
      await _notifications.checkAndNotifyStaleItems(_items, thresholdDays: 0);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}