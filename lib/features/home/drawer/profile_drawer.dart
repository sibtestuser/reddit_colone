import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/Theme/pallete.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logout();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void navigatetoUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(ThemeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 70,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'u/${user.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              title: const Text('My Profile'),
              leading: const Icon(Icons.person),
              onTap: () => navigatetoUserProfile(context, user.uid),
            ),
            ListTile(
              title: const Text('Log Out'),
              leading: Icon(
                Icons.logout,
                color: Pallete.redColor,
              ),
              onTap: () => logOut(ref),
            ),
            Switch.adaptive(
              value: ref.watch(ThemeNotifierProvider.notifier).mode == ThemeMode.dark,
              onChanged: (val) => toggleTheme(ref),
              activeColor: Colors.green[500],
              thumbColor: WidgetStateProperty.all(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
