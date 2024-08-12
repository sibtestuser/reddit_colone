import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/Theme/pallete.dart';
import 'package:reddit_clone2/core/common/error_text.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/features/auth/controller/auth_controller.dart';

import 'package:reddit_clone2/firebase_options.dart';
import 'package:reddit_clone2/model/user_model.dart';
import 'package:reddit_clone2/router.dart';
import 'package:routemaster/routemaster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  Future<void> getData(WidgetRef ref, User data) async {
    userModel = await ref.watch(authControllerProvider.notifier).getUserData(data.uid).first;
    ref.read(userProvider.notifier).update((state) => userModel ?? null);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangeProvider);
    final user = ref.watch(userProvider.notifier).state;
    ref.listen(userProvider, (prev, next) {
      if (prev != next) {
        // ref.read(userProvider.notifier).update((state) => userModel);
        setState(() {
          print('call setState');
        });
      }
    });
    return authState.when(
      data: (data) {
        // print("call first");
        //print("AuthState changed: $data");
        return MaterialApp.router(
          title: 'Reddit Clone',
          theme: ref.watch(ThemeNotifierProvider),
          routerDelegate: RoutemasterDelegate(
            routesBuilder: (context) {
              if (data != null) {
                print("리빌드");
                getData(ref, data);
                if (user != null) {
                  print(user.name);
                  return loggedInRoute;
                }

                print(data.displayName);
              }

              return loggedOutRoute;
            },
          ),
          routeInformationParser: const RoutemasterParser(),
        );
      },
      error: (error, stackTrace) => ErrorText(error: error.toString()),
      loading: () => const Loader(),
    );
  }
}
