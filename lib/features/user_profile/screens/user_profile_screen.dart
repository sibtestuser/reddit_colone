import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/core/common/error_text.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/core/common/post_card.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone2/features/community/controller/community_controller.dart';
import 'package:reddit_clone2/features/user_profile/controller/user_profile_controller.dart';
import 'package:routemaster/routemaster.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  void navigateToUserProfile(BuildContext context) {
    Routemaster.of(context).push('/edit-profile/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
            data: (user) {
              return NestedScrollView(
                headerSliverBuilder: ((context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              user!.banner,
                              fit: BoxFit.cover,
                            ),
                            //child: NetworkImage(community.banner),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(20).copyWith(bottom: 90),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                              radius: 35,
                            ),
                          ),
                          if (uid == ref.watch(userProvider)!.uid)
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(20),
                              child: OutlinedButton(
                                onPressed: () => navigateToUserProfile(context),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.blue, // 글자 색상
                                  side: const BorderSide(color: Colors.blue, width: 1),
                                  padding: const EdgeInsets.symmetric(horizontal: 25), // 외곽선 색상 및 두께
                                ),
                                child: const Text('Edit Profile'),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'u/${user.name}',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('${user.karma} karma'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(thickness: 2),
                          ],
                        ),
                      ),
                    ),
                  ];
                }),
                body: ref.watch(getUserPostProvider(uid)).when(
                      data: (data) {
                        return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final post = data[index];
                            return PostCard(post: post);
                          },
                        );
                      },
                      error: ((error, stackTrace) => ErrorText(error: error.toString())),
                      loading: () => const Loader(),
                    ),
              );
            },
            error: ((error, stackTrace) => ErrorText(error: error.toString())),
            loading: () => const Loader(),
          ),
    );
  }
}
