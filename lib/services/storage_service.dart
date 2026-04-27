import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<String> saveItemPhoto(File imageFile, String itemId) async {
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${dir.path}/photos');
    if (!await photosDir.exists()) await photosDir.create(recursive: true);

    final destPath = '${photosDir.path}/$itemId.jpg';
    await imageFile.copy(destPath);
    return destPath;
  }

  Future<void> deleteItemPhoto(String itemId) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/photos/$itemId.jpg');
    if (await file.exists()) await file.delete();
  }
}