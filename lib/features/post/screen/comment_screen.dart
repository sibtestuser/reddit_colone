import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/core/common/error_text.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/core/common/post_card.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone2/features/post/controller/post_controller.dart';
import 'package:reddit_clone2/features/post/widget/comment_card.dart';
import 'package:reddit_clone2/model/post_model.dart';

class CommnetScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommnetScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommnetScreenState();
}

class _CommnetScreenState extends ConsumerState<CommnetScreen> {
  final commentController = TextEditingController();
  @override
  void dispose() {
    commentController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void addComment(Post post) {
    ref
        .read(PostControllerProvider.notifier)
        .addComment(context: context, text: commentController.text.trim(), post: post);
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (post) {
              return Column(
                children: [
                  PostCard(post: post),
                  const SizedBox(height: 10),
                  if (!isGuest)
                    TextField(
                      onSubmitted: (value) => addComment(post),
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'What are your thoughts?',
                        filled: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ref.watch(PostCommentProvider(post.id)).when(
                        data: (comments) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return CommentCard(comment: comment);
                              },
                            ),
                          );
                        },
                        error: (error, errorTrace) => ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),
                ],
              );
            },
            error: (error, errorTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
