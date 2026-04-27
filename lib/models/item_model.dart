import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemStatus { watching, bought }

class ItemModel {
  final String id;
  final String name;
  final int price;
  final String photoPath; // local file path
  final double lat;
  final double long;
  final String locLabel;
  final List<String> tags;
  final ItemStatus status;
  final DateTime createdAt;
  final DateTime? boughtAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.photoPath,
    required this.lat,
    required this.long,
    required this.locLabel,
    required this.tags,
    required this.status,
    required this.createdAt,
    this.boughtAt,
  });

  int get daysOnList => DateTime.now().difference(createdAt).inDays;

  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      photoPath: data['photo_path'] ?? '',
      lat: (data['lat'] ?? 0.0).toDouble(),
      long: (data['long'] ?? 0.0).toDouble(),
      locLabel: data['loc_label'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      status: data['status'] == 'bought' ? ItemStatus.bought : ItemStatus.watching,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      boughtAt: data['bought_at'] != null
          ? (data['bought_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'photo_path': photoPath,
      'lat': lat,
      'long': long,
      'loc_label': locLabel,
      'tags': tags,
      'status': status == ItemStatus.bought ? 'bought' : 'watching',
      'created_at': Timestamp.fromDate(createdAt),
      'bought_at': boughtAt != null ? Timestamp.fromDate(boughtAt!) : null,
    };
  }

  ItemModel copyWith({
    String? id,
    String? name,
    int? price,
    String? photoPath,
    double? lat,
    double? long,
    String? locLabel,
    List<String>? tags,
    ItemStatus? status,
    DateTime? createdAt,
    DateTime? boughtAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      photoPath: photoPath ?? this.photoPath,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      locLabel: locLabel ?? this.locLabel,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      boughtAt: boughtAt ?? this.boughtAt,
    );
  }
}