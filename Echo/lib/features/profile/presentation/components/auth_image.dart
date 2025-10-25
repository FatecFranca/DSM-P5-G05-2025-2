import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:socialapp/config/api_service.dart';
import 'package:socialapp/features/auth/data/backend_auth_repo.dart';

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
      return FutureBuilder<http.Response>(
        future: http.get(
          Uri.parse(fullImageUrl),
          headers: backendAuthRepo.token != null
              ? {'Authorization': 'Bearer ${backendAuthRepo.token}'}
              : {},
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return placeholder ??
                const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return errorWidget ?? const Icon(Icons.error);
          }

          final resp = snapshot.data;
          if (resp == null) return errorWidget ?? const Icon(Icons.error);

          if (resp.statusCode == 200) {
            final bytes = resp.bodyBytes;
            final provider = MemoryImage(bytes);
            if (imageBuilder != null) {
              return imageBuilder!(context, provider);
            }
            return Image(
              image: provider,
              width: width,
              height: height,
              fit: fit,
            );
          }

          return errorWidget ?? const Icon(Icons.error);
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
    );
  }
}
