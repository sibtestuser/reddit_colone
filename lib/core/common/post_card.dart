import 'package:any_link_preview/any_link_preview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/Theme/pallete.dart';
import 'package:reddit_clone2/core/common/error_text.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/core/constants/constants.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone2/features/community/controller/community_controller.dart';
import 'package:reddit_clone2/features/post/controller/post_controller.dart';
import 'package:reddit_clone2/model/post_model.dart';
import 'package:reddit_clone2/responsive/responsive.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});
  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(PostControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(PostControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(PostControllerProvider.notifier).downvote(post);
  }

  void navigateToUser(BuildContext context, String uid) {
    if (post.uid == uid) Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComment(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref.read(PostControllerProvider.notifier).awardPost(post: post, award: award, context: context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(ThemeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final isGuest = !user.isAuthenticated;
    return Responsive(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: currentTheme.drawerTheme.backgroundColor,
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16).copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => navigateToUser(context, user.uid),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(post.communityProfilePic),
                                        radius: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () => navigateToCommunity(context),
                                            child: Text(
                                              'r/${post.communityName}',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => navigateToUser(context, post.uid),
                                            child: Text(
                                              'u/${post.username}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (post.uid == user.uid)
                                  IconButton(
                                      onPressed: () => deletePost(ref, context),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Pallete.redColor,
                                      ))
                              ],
                            ),
                            if (post.awards.isNotEmpty) ...[
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                height: 25,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                  itemBuilder: (context, index) {
                                    return Image.asset(
                                      Constants.awards[post.awards[index]]!,
                                      height: 23,
                                    );
                                  },
                                ),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isTypeImage)
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.35,
                                width: double.infinity,
                                child: Image.network(
                                  post.link!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (isTypeLink)
                              Padding(
                                padding: const EdgeInsets.all(10),
                                //  height: MediaQuery.of(context).size.height * 0.15,
                                // width: double.infinity,
                                child: AnyLinkPreview(
                                  link: post.link!,
                                  displayDirection: UIDirection.uiDirectionHorizontal,
                                ),
                              ),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: isGuest ? () {} : () => upvotePost(ref),
                                      icon: Icon(
                                        Constants.up,
                                        size: 30,
                                        color: post.upvotes.contains(user.uid) ? Pallete.redColor : null,
                                      ),
                                    ),
                                    Text(
                                      '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    IconButton(
                                      onPressed: isGuest ? () {} : () => downvotePost(ref),
                                      icon: Icon(
                                        Constants.down,
                                        size: 30,
                                        color: post.downvotes.contains(user.uid) ? Pallete.blueColor : null,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => navigateToComment(context),
                                      icon: Icon(
                                        Icons.comment,
                                        size: 30,
                                      ),
                                    ),
                                    Text(
                                      '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                ref.watch(getCommunityByNameProvider(post.communityName)).when(
                                      data: (data) {
                                        if (data.mods.contains(user.uid)) {
                                          return IconButton(
                                            onPressed: () => deletePost(ref, context),
                                            icon: Icon(
                                              Icons.admin_panel_settings,
                                              size: 30,
                                            ),
                                          );
                                        } else {
                                          return const SizedBox();
                                        }
                                      },
                                      error: (error, errorTrace) => ErrorText(error: error.toString()),
                                      loading: () => const Loader(),
                                    ),
                                IconButton(
                                    onPressed: isGuest
                                        ? () {}
                                        : () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: GridView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: user.awards.length,
                                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 4),
                                                    itemBuilder: (context, index) {
                                                      final award = user.awards[index];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          awardPost(ref, award, context);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Image.asset(Constants.awards[award]!),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                    icon: Icon(Icons.card_giftcard_outlined)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
