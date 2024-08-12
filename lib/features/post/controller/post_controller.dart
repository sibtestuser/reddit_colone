import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/core/enums/enums.dart';
import 'package:reddit_clone2/core/providers/firebase_providers.dart';
import 'package:reddit_clone2/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone2/core/utils.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone2/features/post/repository/post_repository.dart';
import 'package:reddit_clone2/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone2/model/comment_model.dart';
import 'package:reddit_clone2/model/community_model.dart';
import 'package:reddit_clone2/model/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final PostControllerProvider = StateNotifierProvider<PostController, bool>((ref) {
  return PostController(
      postRepository: ref.watch(postRepositoryProvider),
      ref: ref,
      storageRepository: ref.watch(firebaseStorageProvider));
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(PostControllerProvider.notifier);
  return postController.getPostById(postId);
});

final PostCommentProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(PostControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void sharedTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String description,
  }) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider);
    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user!.name,
        uid: user!.uid,
        type: 'text',
        createdAt: DateTime.now(),
        awards: [],
        description: description);

    final res = await _postRepository.addPost(post);
    _ref.read(UserProfileControllerProvider.notifier).updateUserKaram(UserKarma.textPost);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Posted Succesfuly');
        Routemaster.of(context).pop();
      },
    );
  }

  void sharedLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
  }) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider);
    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user!.name,
        uid: user.uid,
        type: 'link',
        createdAt: DateTime.now(),
        awards: [],
        link: link);

    final res = await _postRepository.addPost(post);
    _ref.read(UserProfileControllerProvider.notifier).updateUserKaram(UserKarma.linkPost);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Posted Succesfuly');
        Routemaster.of(context).pop();
      },
    );
  }

  void sharedImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
  }) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider);
    final imageRes =
        await _storageRepository.storeFile(path: 'posts/${selectedCommunity.name}', id: postId, file: file);
    _ref.read(UserProfileControllerProvider.notifier).updateUserKaram(UserKarma.imagePost);
    imageRes.fold((l) {
      state = false;
      showSnackBar(context, l.message);
    }, (r) async {
      final Post post = Post(
          id: postId,
          title: title,
          communityName: selectedCommunity.name,
          communityProfilePic: selectedCommunity.avatar,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: user!.name,
          uid: user.uid,
          type: 'image',
          createdAt: DateTime.now(),
          awards: [],
          link: r);

      final res = await _postRepository.addPost(post);
      state = false;
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          showSnackBar(context, 'Posted Succesfuly');
          Routemaster.of(context).pop();
        },
      );
    });
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  Stream<List<Post>> fetchGusetPosts() {
    return _postRepository.fetchGuestPosts();
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    _ref.read(UserProfileControllerProvider.notifier).updateUserKaram(UserKarma.deletePost);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, '삭제되었습니다'),
    );
  }

  void upvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, uid);
  }

  void downvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, uid);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;
    final id = const Uuid().v1();
    Comment commnet = Comment(
        id: id,
        text: text,
        createdAt: DateTime.now(),
        postId: post.id,
        username: user.name,
        profilePic: user.profilePic);
    final res = await _postRepository.addComment(commnet);
    _ref.read(UserProfileControllerProvider.notifier).updateUserKaram(UserKarma.comments);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  void awardPost({required Post post, required String award, required BuildContext context}) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepository.awardPost(post, award, user.uid);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(UserProfileControllerProvider.notifier).updateUserKaram(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}
