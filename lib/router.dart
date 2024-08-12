//logged out

//logged In

import 'package:flutter/material.dart';
import 'package:reddit_clone2/features/auth/screens/login_screen.dart';
import 'package:reddit_clone2/features/community/screen/add_mods_screen.dart';
import 'package:reddit_clone2/features/community/screen/community_screen.dart';
import 'package:reddit_clone2/features/community/screen/create_community_screen.dart';
import 'package:reddit_clone2/features/community/screen/edit_community.dart';
import 'package:reddit_clone2/features/community/screen/mod_tools_screen.dart';
import 'package:reddit_clone2/features/home/screens/home_screen.dart';
import 'package:reddit_clone2/features/post/screen/add_post_screen.dart';
import 'package:reddit_clone2/features/post/screen/add_post_type_screen.dart';
import 'package:reddit_clone2/features/post/screen/comment_screen.dart';
import 'package:reddit_clone2/features/user_profile/screens/edit_profile_screen.dart';
import 'package:reddit_clone2/features/user_profile/screens/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) => const MaterialPage(child: CreateComminityScreen()),
  '/r/:name': (route) {
    final encodedName = Uri.decodeComponent(route.pathParameters['name']!);
    return MaterialPage(
        child: CommunityScreen(
      name: encodedName,
    ));
  },
  '/mod-tools/:name': (routeData) {
    final encodedName = Uri.decodeComponent(routeData.pathParameters['name']!);
    return MaterialPage(
        child: ModToolScreen(
      name: encodedName,
    ));
  },
  '/edit-community/:name': (routeData) {
    final encodedName = Uri.decodeComponent(routeData.pathParameters['name']!);
    return MaterialPage(
        child: EditCommunityScreen(
      name: encodedName,
    ));
  },
  '/add-mods/:name': (routeData) {
    final encodedName = Uri.decodeComponent(routeData.pathParameters['name']!);
    return MaterialPage(
        child: AddModsScreen(
      name: encodedName,
    ));
  },
  '/u/:uid': (routeData) {
    final encodeduid = Uri.decodeComponent(routeData.pathParameters['uid']!);
    return MaterialPage(
        child: UserProfileScreen(
      uid: encodeduid,
    ));
  },
  '/edit-profile/:uid': (routeData) {
    final encodeduid = Uri.decodeComponent(routeData.pathParameters['uid']!);
    return MaterialPage(
        child: EditProfileScreen(
      uid: encodeduid,
    ));
  },
  '/add-post/:type': (routeData) {
    final encodedtype = Uri.decodeComponent(routeData.pathParameters['type']!);
    return MaterialPage(
        child: AddPostTypeScreen(
      type: encodedtype,
    ));
  },
  '/post/:postId/comments': (routeData) {
    final encodedpostId = Uri.decodeComponent(routeData.pathParameters['postId']!);
    return MaterialPage(
        child: CommnetScreen(
      postId: encodedpostId,
    ));
  },
  '/add-post': (routeData) {
    return MaterialPage(child: AddPostScreen());
  },
});
