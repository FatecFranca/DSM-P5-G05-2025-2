import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/config/api_service.dart';
import 'package:socialapp/features/auth/data/backend_auth_repo.dart';
import 'package:socialapp/features/storage/data/image_cache_service.dart';

class AuthImage extends StatelessWidget {
  final String userId;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Widget Function(BuildContext, ImageProvider)? imageBuilder;

  const AuthImage({
    super.key,
    required this.userId,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final backendAuthRepo = context.read<BackendAuthRepo>();

    final fullImageUrl = Uri.parse(
      '${ApiService.baseUrl}profile/$userId/image',
    ).toString();

    if (kIsWeb) {
      final cacheService = ImageCacheService();
      final headers = backendAuthRepo.token != null
          ? <String, String>{'Authorization': 'Bearer ${backendAuthRepo.token}'}
          : <String, String>{};

      return FutureBuilder<Uint8List?>(
        future: cacheService.getImage(fullImageUrl, headers),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return placeholder ??
                const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return errorWidget ?? const Icon(Icons.error);
          }

          final bytes = snapshot.data!;
          final provider = MemoryImage(bytes);
          if (imageBuilder != null) {
            return imageBuilder!(context, provider);
          }
          return Image(image: provider, width: width, height: height, fit: fit);
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      httpHeaders: backendAuthRepo.token != null
          ? {'Authorization': 'Bearer ${backendAuthRepo.token}'}
          : null,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ?? const CircularProgressIndicator(),
      errorWidget: (context, url, error) =>
          errorWidget ?? const Icon(Icons.error),
      imageBuilder: imageBuilder,
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }
}
