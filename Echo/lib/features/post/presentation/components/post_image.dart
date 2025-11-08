import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/config/api_service.dart';
import 'package:socialapp/features/auth/data/backend_auth_repo.dart';
import 'package:socialapp/features/storage/data/image_cache_service.dart';

class PostImage extends StatefulWidget {
  final String postId;
  final String imageId;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Widget Function(BuildContext, ImageProvider)? imageBuilder;

  const PostImage({
    super.key,
    required this.postId,
    required this.imageId,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.imageBuilder,
  });

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  Uint8List? _cachedBytes;
  bool _isLoading = false;
  bool _hasError = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialized = true;
      if (kIsWeb) _loadImage();
    });
  }

  @override
  void didUpdateWidget(PostImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId ||
        oldWidget.imageId != widget.imageId) {
      _cachedBytes = null;
      _hasError = false;
      if (kIsWeb && _initialized) _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (_cachedBytes != null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final backendAuthRepo = context.read<BackendAuthRepo>();
    final fullImageUrl =
        '${ApiService.baseUrl}posts/${widget.postId}/images/${widget.imageId}';

    final Map<String, String> headers = backendAuthRepo.token != null
        ? {'Authorization': 'Bearer ${backendAuthRepo.token}'}
        : <String, String>{};

    try {
      final bytes = await ImageCacheService().getImage(fullImageUrl, headers);
      if (mounted) {
        setState(() {
          _cachedBytes = bytes;
          _isLoading = false;
          _hasError = bytes == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backendAuthRepo = context.read<BackendAuthRepo>();
    final fullImageUrl =
        '${ApiService.baseUrl}posts/${widget.postId}/images/${widget.imageId}';
    final fixedHeight = widget.height ?? 300.0;

    if (kIsWeb) {
      if (_isLoading) {
        return SizedBox(
          width: widget.width,
          height: fixedHeight,
          child:
              widget.placeholder ??
              const Center(child: CircularProgressIndicator()),
        );
      }

      if (_hasError || _cachedBytes == null) {
        return SizedBox(
          width: widget.width,
          height: fixedHeight,
          child: widget.errorWidget ?? const Icon(Icons.error),
        );
      }

      try {
        final provider = MemoryImage(_cachedBytes!);
        if (widget.imageBuilder != null) {
          return widget.imageBuilder!(context, provider);
        }

        return Image(
          image: provider,
          width: widget.width,
          height: fixedHeight,
          fit: widget.fit ?? BoxFit.cover,
        );
      } catch (_) {
        return SizedBox(
          width: widget.width,
          height: fixedHeight,
          child: widget.errorWidget ?? const Icon(Icons.broken_image),
        );
      }
    }

    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      httpHeaders: backendAuthRepo.token != null
          ? {'Authorization': 'Bearer ${backendAuthRepo.token}'}
          : null, // <-- CORRETO
      width: widget.width,
      height: fixedHeight,
      fit: widget.fit ?? BoxFit.cover,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (context, url) => SizedBox(
        height: fixedHeight,
        child:
            widget.placeholder ??
            const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => SizedBox(
        height: fixedHeight,
        child: widget.errorWidget ?? const Icon(Icons.error),
      ),
      imageBuilder: widget.imageBuilder,
      memCacheWidth: widget.width?.toInt(),
      memCacheHeight: fixedHeight.toInt(),
    );
  }
}
