import 'dart:typed_data';
import 'ico_image.dart';

class IcoWriter {
  Uint8List encode(List<IcoImage> images) {
    final fileData = BytesBuilder();
    final header = ByteData(6);
    header.setUint16(0, 0, Endian.little); // Reserved
    header.setUint16(2, 1, Endian.little); // Image type (1 = icon)
    header.setUint16(4, images.length, Endian.little); // Image count
    fileData.add(header.buffer.asUint8List());

    final imageDataList = <Uint8List>[];
    int offset = 6 + (16 * images.length); // Header + directory entries

    for (final image in images) {
      final entry = ByteData(16);
      entry.setUint8(0, image.width == 256 ? 0 : image.width);
      entry.setUint8(1, image.height == 256 ? 0 : image.height);
      entry.setUint8(2, 0); // Color count
      entry.setUint8(3, 0); // Reserved
      entry.setUint16(4, 1, Endian.little); // Color planes
      entry.setUint16(6, 32, Endian.little); // Bits per pixel
      entry.setUint32(8, image.imageData.length, Endian.little); // Size of image data
      entry.setUint32(12, offset, Endian.little); // Offset of image data
      fileData.add(entry.buffer.asUint8List());

      imageDataList.add(image.imageData);
      offset += image.imageData.length;
    }

    for (final data in imageDataList) {
      fileData.add(data);
    }

    return fileData.toBytes();
  }
}
