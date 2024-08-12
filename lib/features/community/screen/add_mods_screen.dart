import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/core/common/error_text.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone2/features/community/controller/community_controller.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  const AddModsScreen({super.key, required this.name});
  final String name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};
  int ctr = 0;

  void addUids(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUids(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref.read(communityControllerProvider.notifier).addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: Icon(Icons.done),
          ),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (community) {
              return ListView.builder(
                itemCount: community.members.length,
                itemBuilder: (context, index) {
                  final member = community.members[index];
                  return ref.watch(getUserDataProvider(member)).when(
                        data: (user) {
                          if (community.mods.contains(member)) {
                            uids.add(member);
                          }
                          return CheckboxListTile(
                            value: uids.contains(user!.uid),
                            onChanged: (val) {
                              if (val!) {
                                addUids(user.uid);
                              } else {
                                removeUids(user.uid);
                              }
                            },
                            title: Text(
                              user!.name,
                            ),
                          );
                        },
                        error: (error, trace) => ErrorText(error: error.toString()),
                        loading: () => Loader(),
                      );
                },
              );
            },
            error: (error, trace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
