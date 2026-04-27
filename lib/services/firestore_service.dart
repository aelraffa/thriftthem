import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _itemsCollection(String uid) {
    return _db.collection('users').doc(uid).collection('items');
  }

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Stream<List<ItemModel>> watchItems() {
    return _itemsCollection(_uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ItemModel.fromFirestore(d)).toList());
  }

  Future<void> addItem(ItemModel item) async {
    await _itemsCollection(_uid).doc(item.id).set(item.toFirestore());
  }

  Future<void> updateItem(ItemModel item) async {
    await _itemsCollection(_uid).doc(item.id).update(item.toFirestore());
  }

  Future<void> deleteItem(String itemId) async {
    await _itemsCollection(_uid).doc(itemId).delete();
  }

  Future<void> markAsBought(String itemId) async {
    await _itemsCollection(_uid).doc(itemId).update({
      'status': 'bought',
      'bought_at': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<List<ItemModel>> getWatchingItems() async {
    final snap = await _itemsCollection(_uid)
        .where('status', isEqualTo: 'watching')
        .get();
    return snap.docs.map((d) => ItemModel.fromFirestore(d)).toList();
  }
}