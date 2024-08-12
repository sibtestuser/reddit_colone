import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/core/common/error_text.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/core/common/sign_in_button.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone2/features/community/controller/community_controller.dart';
import 'package:reddit_clone2/model/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, Community community) {
    print(community.name);
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            isGuest
                ? const SignInButton(
                    isFromLogin: false,
                  )
                : ListTile(
                    title: const Text('Create a Community'),
                    leading: const Icon(Icons.add),
                    onTap: () => navigateToCreateCommunity(context),
                  ),
            if (!isGuest)
              ref.watch(userCommunitiesProvider).when(
                    data: (communities) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: communities.length,
                          itemBuilder: (context, index) {
                            final community = communities[index];
                            return ListTile(
                              title: Text('r/${community.name}'),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                              onTap: () {
                                navigateToCommunity(context, community);
                              },
                            );
                          },
                        ),
                      );
                    },
                    error: (error, stacktrace) => ErrorText(error: error.toString()),
                    loading: () => const Loader(),
                  ),
          ],
        ),
      ),
    );
  }
}
