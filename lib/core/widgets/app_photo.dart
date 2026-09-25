import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';

class AppPhoto extends StatelessWidget {
  const AppPhoto.file(
    this.filePath, {
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    super.key,
  }) : imageUrl = null;

  const AppPhoto.network(
    this.imageUrl, {
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    super.key,
  }) : filePath = null;

  final String? filePath;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget image = imageUrl != null
        ? CachedNetworkImage(
            imageUrl: imageUrl!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, _) => const _PhotoPlaceholder(),
            errorWidget: (_, _, _) => const _PhotoError(),
          )
        : Image.file(
            File(filePath!),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => const _PhotoError(),
          );

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadii.card),
      child: SizedBox(width: width, height: height, child: image),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.hairline,
      highlightColor: AppColors.background,
      child: Container(color: AppColors.hairline),
    );
  }
}

class _PhotoError extends StatelessWidget {
  const _PhotoError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.hairline,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.faintText,
      ),
    );
  }
}
