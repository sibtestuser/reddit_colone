import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/core/enums/enums.dart';

import 'package:reddit_clone2/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone2/core/utils.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone2/features/user_profile/repository/user_profile_repository.dart';
import 'package:reddit_clone2/model/post_model.dart';
import 'package:reddit_clone2/model/user_model.dart';
import 'package:routemaster/routemaster.dart';

final UserProfileControllerProvider = StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(firebaseStorageProvider);
  return UserProfileController(
      userprofilerepository: userProfileRepository, ref: ref, storageRepository: storageRepository);
});

final getUserPostProvider = StreamProvider.family((ref, String uid) {
  return ref.watch(UserProfileControllerProvider.notifier).getUserPost(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  UserProfileController({
    required UserProfileRepository userprofilerepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _userProfileRepository = userprofilerepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void editProfile(
      {required File? profileFile,
      required File? bannerFiel,
      required BuildContext context,
      required String name}) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(path: 'users/profile', id: user.uid, file: profileFile);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }
    if (bannerFiel != null) {
      final res = await _storageRepository.storeFile(path: 'users/banner', id: user.uid, file: bannerFiel);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }
    user = user.copyWith(name: name);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Post>> getUserPost(String uid) {
    return _userProfileRepository.getUserPost(uid);
  }

  void updateUserKaram(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);
    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold((l) => null, (r) => _ref.read(userProvider.notifier).update((state) => user));
  }
}
