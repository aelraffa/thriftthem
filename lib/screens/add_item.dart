import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import '../widgets/tag_chip.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _locationService = LocationService();

  File? _imageFile;
  double? _lat;
  double? _long;
  String _locLabel = '';
  List<String> _tags = [];
  bool _isGettingLocation = false;

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
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
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
    if (_priceCtrl.text.trim().isEmpty) {
      _showError('Please enter a price.');
      return;
    }
    if (_imageFile == null) {
      _showError('Please take a photo of the item.');
      return;
    }
    if (_lat == null) {
      _showError('Please pin the store location.');
      return;
    }

    final price = int.tryParse(_priceCtrl.text.replaceAll(RegExp(r'[^\d]'), ''));
    if (price == null) {
      _showError('Invalid price.');
      return;
    }

    await context.read<ItemProvider>().addItem(
      name: _nameCtrl.text.trim(),
      price: price,
      imageFile: _imageFile!,
      lat: _lat!,
      long: _long!,
      locLabel: _locLabel,
      tags: _tags,
    );

    if (mounted) Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ItemProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Find'),
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
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageFile != null
                        ? AppColors.primary
                        : AppColors.border,
                    width: _imageFile != null ? 1.5 : 0.5,
                  ),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt_outlined,
                        size: 36, color: AppColors.primary),
                    SizedBox(height: 8),
                    Text('Tap to take photo',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500)),
                  ],
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

            // Location pin
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
                  color: _lat != null
                      ? AppColors.primaryLight
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _lat != null
                        ? AppColors.primary
                        : AppColors.border,
                    width: _lat != null ? 1.5 : 0.5,
                  ),
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
                        : Icon(
                      _lat != null
                          ? Icons.location_on
                          : Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isGettingLocation
                            ? 'Getting location...'
                            : _lat != null
                            ? _locLabel
                            : 'Tap to pin store location',
                        style: TextStyle(
                          fontSize: 14,
                          color: _lat != null
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (_lat != null)
                      const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 18),
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
                      hintText: 'e.g. denim, vintage, jacket',
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
                  onDelete: () =>
                      setState(() => _tags.remove(t)),
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