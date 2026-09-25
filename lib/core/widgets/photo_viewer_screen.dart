import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../theme/colors.dart';

/// Full-screen photo viewer with pinch-to-zoom and pan (`photo_view`).
class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen.file(this.filePath, {this.heroTag, super.key})
    : imageUrl = null;

  const PhotoViewerScreen.network(this.imageUrl, {this.heroTag, super.key})
    : filePath = null;

  final String? filePath;
  final String? imageUrl;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final ImageProvider provider = imageUrl != null
        ? CachedNetworkImageProvider(imageUrl!)
        : FileImage(File(filePath!));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: PhotoView(
        imageProvider: provider,
        heroAttributes: heroTag == null
            ? null
            : PhotoViewHeroAttributes(tag: heroTag!),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder: (_, _) => const Center(
          child: CircularProgressIndicator(color: AppColors.surface),
        ),
        errorBuilder: (_, _, _) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.faintText,
            size: 48,
          ),
        ),
      ),
    );
  }
}
