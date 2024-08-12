import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/core/common/error_text.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/features/community/controller/community_controller.dart';
import 'package:reddit_clone2/model/community_model.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchCommunityDelegate(this.ref);
  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommunityProvider(query)).when(
          data: (communities) {
            return ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final community = communities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(community.avatar),
                  ),
                  title: Text('r/${community.name}'),
                  onTap: () {
                    navigateToCommunity(context, community.name);
                  },
                );
              },
            );
          },
          error: (error, errortrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }

  void navigateToCommunity(BuildContext context, String communityname) {
    //  print(community.name);
    Routemaster.of(context).push('/r/$communityname');
  }
}
