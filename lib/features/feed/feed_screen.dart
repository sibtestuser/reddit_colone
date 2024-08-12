import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/core/common/error_text.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/core/common/post_card.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone2/features/community/controller/community_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    if (isGuest) {
      return ref.watch(userCommunitiesProvider).when(
            data: (data) {
              return ref.watch(guestPostsStreamProvider).when(
                    data: (data) {
                      return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final post = data[index];
                            return PostCard(post: post);
                          });
                    },
                    error: (error, stacktrace) {
                      return ErrorText(error: error.toString());
                    },
                    loading: () => const Loader(),
                  );
            },
            error: (error, stacktrace) {
              //print(error);
              return ErrorText(error: error.toString());
            },
            loading: () => const Loader(),
          );
    }
    return ref.watch(userCommunitiesProvider).when(
          data: (data) {
            return ref.watch(userPostsStreamProvider(data)).when(
                  data: (data) {
                    return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final post = data[index];
                          return PostCard(post: post);
                        });
                  },
                  error: (error, stacktrace) {
                    print(error);
                    return ErrorText(error: error.toString());
                  },
                  loading: () => const Loader(),
                );
          },
          error: (error, stacktrace) {
            //print(error);
            return ErrorText(error: error.toString());
          },
          loading: () => const Loader(),
        );
  }
}
