import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/Theme/pallete.dart';
import 'package:reddit_clone2/core/constants/constants.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone2/features/home/delegate/search_community_delegate.dart';
import 'package:reddit_clone2/features/home/drawer/community_list_drawer.dart';
import 'package:reddit_clone2/features/home/drawer/profile_drawer.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;
  void dispalyDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void dispalyEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(ThemeNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => dispalyDrawer(context),
            icon: const Icon(Icons.menu),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchCommunityDelegate(ref),
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
              onPressed: () {
                Routemaster.of(context).pop('add-post');
              },
              icon: Icon(Icons.add)),
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(
                  user?.profilePic ??
                      'https://www.google.com/url?sa=i&url=https%3A%2F%2Ffirpeng.tistory.com%2F103&psig=AOvVaw3NS4H5CAOOxdAtXKFTijMt&ust=1722511184008000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLDy9a2U0YcDFQAAAAAdAAAAABAE',
                ),
              ),
              onPressed: () => dispalyEndDrawer(context),
            );
          }),
        ],
      ),
      body: Constants.tabWidgets[_page],
      drawer: const CommunityListDrawer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      bottomNavigationBar: isGuest || kIsWeb
          ? null
          : CupertinoTabBar(
              activeColor: currentTheme.iconTheme.color,
              backgroundColor: currentTheme.scaffoldBackgroundColor,
              currentIndex: _page,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: '',
                ),
              ],
              onTap: onPageChanged,
            ),
    );
  }
}
