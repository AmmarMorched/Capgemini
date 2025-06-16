import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  // Encode File to Base64 String
  static String? encodeImageToBase64(File? imageFile) {
    if (imageFile == null || !imageFile.existsSync()) return null;

    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }

  // Decode Base64 String to Uint8List
  static Uint8List? decodeBase64ToImageBytes(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      print("❌ Failed to decode Base64: $e");
      return null;
    }
  }

  // Compress image before saving
  static Future<Uint8List?> compressAndEncodeImage(File imageFile) async {
    if (!imageFile.existsSync()) return null;

    final originalBytes = await imageFile.readAsBytes();
    final compressedData = await FlutterImageCompress.compressWithList(
      originalBytes,
      minHeight: 300,
      minWidth: 300,
      quality: 60,
    );
    return compressedData;
  }
}