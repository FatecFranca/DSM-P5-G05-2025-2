import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/domain/entities/app_user.dart';
import 'package:socialapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/post/domain/entities/post.dart';
import 'package:socialapp/features/post/presentation/cubits/post_states.dart';
import 'package:socialapp/features/post/presentation/cubits/posts_cubit.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  List<PlatformFile> imagePickedFiles = [];

  List<Uint8List> webImages = [];

  TextEditingController? _textController;
  TextEditingController get textController {
    _textController ??= TextEditingController();
    return _textController!;
  }

  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    if (!mounted) return;
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFiles.addAll(result.files);

        if (kIsWeb) {
          webImages.addAll(
            result.files.where((f) => f.bytes != null).map((f) => f.bytes!),
          );
        }
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      imagePickedFiles.removeAt(index);
      if (kIsWeb) {
        webImages.removeAt(index);
      }
    });
  }

  Future<void> uploadPost() async {
    if (!mounted) return;

    if (imagePickedFiles.isEmpty || textController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Both text and at least one image are required"),
        ),
      );
      return;
    }

    final newPost = Post(
      id: '0',
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageIds: [],
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );

    try {
      if (!mounted) return;
      final postCubit = context.read<PostCubit>();

      final createdPost = await postCubit.createPost(newPost);

      if (kIsWeb) {
        if (webImages.isNotEmpty) {
          await postCubit.uploadPostImages(createdPost.id, webImages);
        }
      } else {
        if (imagePickedFiles.isNotEmpty) {
          final imageBytes = await Future.wait(
            imagePickedFiles.map((file) => File(file.path!).readAsBytes()),
          );

          await postCubit.uploadPostImages(createdPost.id, imageBytes);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading post: $e")));
    }
  }

  void _disposeController() {
    if (_textController != null) {
      _textController!.dispose();
      _textController = null;
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          _disposeController();
        }
      },
      child: BlocConsumer<PostCubit, PostState>(
        builder: (context, state) {
          // loading or uploading..
          if (state is PostsLoading || state is PostUploading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // build upload page
          return buildUploadPage();
        },

        // go to previous page when upload is done & posts are loaded
        listener: (context, state) async {
          if (state is PostsLoaded && mounted) {
            _disposeController();
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: uploadPost, icon: const Icon(Icons.upload)),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    MyTextField(
                      controller: textController,
                      hintText: "Write a caption...",
                      obscureText: false,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              if (imagePickedFiles.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: kIsWeb
                                ? Image.memory(
                                    webImages[index],
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(imagePickedFiles[index].path!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () => removeImage(index),
                                customBorder: const CircleBorder(),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onError,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      childCount: imagePickedFiles.length,
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: imagePickedFiles.isEmpty ? 200 : 80,
                    child: MaterialButton(
                      onPressed: pickImages,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: imagePickedFiles.isEmpty ? 48 : 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            imagePickedFiles.isEmpty
                                ? "Add Photos"
                                : "Add More Photos",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: imagePickedFiles.isEmpty ? 16 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
