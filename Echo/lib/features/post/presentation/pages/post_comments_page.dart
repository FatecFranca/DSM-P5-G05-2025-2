import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/domain/entities/app_user.dart';
import 'package:socialapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/post/domain/entities/comment.dart';
import 'package:socialapp/features/post/domain/entities/post.dart';
import 'package:socialapp/features/post/presentation/components/comment_tile.dart';
import 'package:socialapp/features/post/presentation/cubits/posts_cubit.dart';

class PostCommentsPage extends StatefulWidget {
  final Post post;

  const PostCommentsPage({super.key, required this.post});

  @override
  State<PostCommentsPage> createState() => _PostCommentsPageState();
}

class _PostCommentsPageState extends State<PostCommentsPage> {
  late final postCubit = context.read<PostCubit>();
  AppUser? currentUser;
  List<Comment> comments = [];
  bool isLoading = true;
  final commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchComments();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> fetchComments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedComments = await postCubit.fetchPostComments(widget.post.id);
      setState(() {
        comments = fetchedComments;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addComment() {
    if (commentTextController.text.isNotEmpty && currentUser != null) {
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: widget.post.id,
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: commentTextController.text,
        timestamp: DateTime.now(),
      );

      postCubit.addComment(widget.post.id, newComment).then((_) {
        fetchComments();
        commentTextController.clear();
      });
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await postCubit.deleteComment(widget.post.id, commentId);
      fetchComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar comentário: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comentários"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                ? const Center(child: Text("Nenhum comentário ainda"))
                : RefreshIndicator(
                    onRefresh: fetchComments,
                    child: ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return CommentTile(
                          comment: comment,
                          onDeleted: () => deleteComment(comment.id),
                        );
                      },
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: commentTextController,
                    hintText: "Digite um comentário...",
                    obscureText: false,
                  ),
                ),
                IconButton(onPressed: addComment, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
