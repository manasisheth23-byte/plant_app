import 'dart:io';
import 'package:erpflutter/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreview extends StatelessWidget {
  final String filePath;
  ImagePreview({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.APPCOLOR,
          foregroundColor: Colors.white,
          title: Text("Preview")),
      body: PhotoView(
        imageProvider: FileImage(File(filePath)),
      ),
    );
  }
}

// Usage:

