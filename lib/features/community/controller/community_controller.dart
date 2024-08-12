import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone2/core/constants/constants.dart';
import 'package:reddit_clone2/core/failure.dart';
import 'package:reddit_clone2/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone2/core/utils.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone2/features/community/repository/community_repsository.dart';
import 'package:reddit_clone2/features/post/controller/post_controller.dart';
import 'package:reddit_clone2/model/community_model.dart';
import 'package:reddit_clone2/model/post_model.dart';
import 'package:routemaster/routemaster.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  return ref.watch(communityControllerProvider.notifier).getUserCommunities();
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref.watch(communityControllerProvider.notifier).getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

final userPostsStreamProvider = StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(PostControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

final guestPostsStreamProvider = StreamProvider((ref) {
  final postController = ref.watch(PostControllerProvider.notifier);
  return postController.fetchGusetPosts();
});

final getCommunityPostProvider = StreamProvider.family((ref, String name) {
  return ref.watch(communityControllerProvider.notifier).getCommunityPosts(name);
});

final communityControllerProvider = StateNotifierProvider<CommunityController, bool>((ref) {
  return CommunityController(
    communityRepository: ref.watch(communityRepositoryProvider),
    ref: ref,
    storageRepository: ref.watch(firebaseStorageProvider),
  );
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    final uid = _ref.read(userProvider)?.uid ?? '';
    name = name.replaceAll(' ', '_');
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    state = true;
    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Community Created Successfully');
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.watch(userProvider)!.uid;
    return _communityRepository.getUserCommunity(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    name = name.replaceAll(' ', '_');
    return _communityRepository.getCommunityByName(name);
  }

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!;
    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        if (community.members.contains(user.uid)) {
          showSnackBar(context, '탈퇴하였습니다.');
          print('탈퇴');
        } else {
          showSnackBar(context, '가입하였습니다.');
          print('가입');
        }
      },
    );
  }

  void editCommunity(
      {required File? profileFile,
      required File? bannerFiel,
      required Community community,
      required BuildContext context}) async {
    if (profileFile != null) {
      state = true;
      final res =
          await _storageRepository.storeFile(path: 'communities/profile', id: community.name, file: profileFile);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(avatar: r),
      );
    }
    if (bannerFiel != null) {
      final res = await _storageRepository.storeFile(path: 'communities/banner', id: community.name, file: bannerFiel);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  void addMods(String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepository.getCommunityPosts(name);
  }
}
