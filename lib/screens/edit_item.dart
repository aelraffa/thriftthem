import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import '../widgets/tag_chip.dart';

class EditItemScreen extends StatefulWidget {
  final ItemModel item;
  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  final TextEditingController _tagCtrl = TextEditingController();
  final _locationService = LocationService();

  File? _newImageFile;
  late double _lat;
  late double _long;
  late String _locLabel;
  late List<String> _tags;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _priceCtrl = TextEditingController(text: widget.item.price.toString());
    _lat = widget.item.lat;
    _long = widget.item.long;
    _locLabel = widget.item.locLabel;
    _tags = List.from(widget.item.tags);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (picked != null) setState(() => _newImageFile = File(picked.path));
  }

  Future<void> _pinLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final pos = await _locationService.getCurrentPosition();
      final label =
      await _locationService.getAddressFromCoords(pos.latitude, pos.longitude);
      setState(() {
        _lat = pos.latitude;
        _long = pos.longitude;
        _locLabel = label;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not get location: $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _addTag(String tag) {
    final t = tag.trim().toLowerCase();
    if (t.isNotEmpty && !_tags.contains(t)) {
      setState(() {
        _tags.add(t);
        _tagCtrl.clear();
      });
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter an item name.');
      return;
    }
    final price =
    int.tryParse(_priceCtrl.text.replaceAll(RegExp(r'[^\d]'), ''));
    if (price == null) {
      _showError('Invalid price.');
      return;
    }

    await context.read<ItemProvider>().updateItem(
      existing: widget.item,
      name: _nameCtrl.text.trim(),
      price: price,
      newImageFile: _newImageFile,
      lat: _lat,
      long: _long,
      locLabel: _locLabel,
      tags: _tags,
    );

    if (mounted) Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ItemProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Find'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _save,
            child: isLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            )
                : const Text('Save',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _newImageFile != null
                          ? Image.file(_newImageFile!, fit: BoxFit.cover)
                          : Image.file(File(widget.item.photoPath), fit: BoxFit.cover),
                      Container(
                        color: Colors.black.withOpacity(0.25),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.white, size: 28),
                              SizedBox(height: 6),
                              Text('Retake photo',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Item name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),

            // Price
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (Rp)',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 20),

            // Location
            const Text('Location',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isGettingLocation ? null : _pinLocation,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Row(
                  children: [
                    _isGettingLocation
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                        : const Icon(Icons.location_on,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isGettingLocation
                            ? 'Getting location...'
                            : _locLabel,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primaryDark),
                      ),
                    ),
                    const Text('Re-pin',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tags
            const Text('Tags',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a tag',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    onSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _addTag(_tagCtrl.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags
                    .map((t) => TagChip(
                  label: t,
                  onDelete: () => setState(() => _tags.remove(t)),
                ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}