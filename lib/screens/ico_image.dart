import 'dart:typed_data';

class IcoImage {
  final Uint8List imageData;
  final int width;
  final int height;

  IcoImage(this.imageData, {required this.width, required this.height});
}
