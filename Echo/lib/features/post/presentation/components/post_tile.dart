import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/domain/entities/app_user.dart';
import 'package:socialapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/post/domain/entities/comment.dart';
import 'package:socialapp/features/post/domain/entities/post.dart';
import 'package:socialapp/features/post/domain/entities/post_image.dart'
    as domain;
import 'package:socialapp/features/post/presentation/components/post_image.dart';
import 'package:socialapp/features/post/presentation/cubits/posts_cubit.dart';
import 'package:socialapp/features/post/presentation/pages/post_comments_page.dart';
import 'package:socialapp/features/profile/domain/entities/profile_user.dart';
import 'package:socialapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialapp/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile>
    with AutomaticKeepAliveClientMixin {
  // Cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;
  AppUser? currentUser;
  ProfileUser? postUser;

  List<domain.PostImage> postImages = [];
  bool isLoadingImages = false;
  bool _hasLoadedImages = false;

  final double _imageHeight = 430; // 🔒 altura fixa das imagens

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
    fetchPostImages();
  }

  @override
  void didUpdateWidget(PostTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _hasLoadedImages = false;
      postImages.clear();
      fetchPostImages();
    }
  }

  Future<void> fetchPostImages() async {
    if (_hasLoadedImages) return;

    setState(() => isLoadingImages = true);

    try {
      final images = await postCubit.fetchPostImages(widget.post.id);
      if (!mounted) return;

      // pré-carregar as imagens para evitar layout shift
      for (final img in images) {
        final imageId = img.path.split('/').last;
        final imageWidget = PostImage(
          postId: widget.post.id,
          imageId: imageId,
          height: _imageHeight,
          width: double.infinity,
          fit: BoxFit.cover,
        );
        // precache
        await precacheImage(
          CachedNetworkImageProvider(
            "${widget.post.id}/images/$imageId",
          ), // substitua se necessário
          context,
        ).catchError((_) {});
      }

      setState(() {
        postImages = images;
        isLoadingImages = false;
        _hasLoadedImages = true;
      });
    } catch (e) {
      if (mounted) setState(() => isLoadingImages = false);
    }
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser?.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null && mounted) {
      setState(() => postUser = fetchedUser);
    }
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((_) {
      setState(() {
        if (isLiked) {
          widget.post.likes.remove(currentUser!.uid);
        } else {
          widget.post.likes.add(currentUser!.uid);
        }
      });
    });
  }

  final commentTextController = TextEditingController();

  void openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: MyTextField(
          controller: commentTextController,
          hintText: "Type a comment",
          obscureText: false,
        ),
        actions: [
          TextButton(
            onPressed: () {
              commentTextController.clear();
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              addComment();
              commentTextController.clear();
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void addComment() {
    if (commentTextController.text.isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    postCubit.addComment(widget.post.id, newComment);
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              widget.onDeletePressed?.call();
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void openCommentsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostCommentsPage(post: widget.post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // necessário pro AutomaticKeepAlive funcionar

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(uid: widget.post.userId),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          imageBuilder: (context, provider) => CircleAvatar(
                            radius: 20,
                            backgroundImage: provider,
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                        )
                      : const Icon(Icons.person),
                  const SizedBox(width: 10),
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isOwnPost)
                    IconButton(
                      onPressed: showOptions,
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // image block (altura fixa 🔒)
          SizedBox(
            height: _imageHeight,
            width: double.infinity,
            child: isLoadingImages
                ? const Center(child: CircularProgressIndicator())
                : (postImages.isEmpty
                      ? Container(color: Colors.grey[900])
                      : PageView.builder(
                          itemCount: postImages.length,
                          itemBuilder: (context, index) {
                            final image = postImages[index];
                            final imageId = image.path.split('/').last;
                            return PostImage(
                              postId: widget.post.id,
                              imageId: imageId,
                              width: double.infinity,
                              height: _imageHeight,
                              fit: BoxFit.cover,
                              placeholder: const SizedBox(height: 430),
                              errorWidget: const Icon(Icons.error),
                            );
                          },
                        )),
          ),

          // footer
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: toggleLikePost,
                  child: Icon(
                    Icons.favorite_border,
                    color: widget.post.likes.contains(currentUser!.uid)
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.post.likes.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: openCommentsPage,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  "${widget.post.timestamp.day}/${widget.post.timestamp.month}/${widget.post.timestamp.year} ${widget.post.timestamp.hour.toString().padLeft(2, '0')}:${widget.post.timestamp.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0,
            ),
            child: Row(
              children: [
                Text(
                  widget.post.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.post.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
