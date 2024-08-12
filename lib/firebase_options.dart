// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBK6Uamydh0SafHdL8uowFj82O2xGVZ9vU',
    appId: '1:495828605007:android:1e8444997a54490df5723a',
    messagingSenderId: '495828605007',
    projectId: 'reddit-clone-b8463',
    storageBucket: 'reddit-clone-b8463.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBOyeCHm3v4t47yDsbex5Aw3m86jj5oGg0',
    appId: '1:495828605007:ios:2fab9a8074f9d3e8f5723a',
    messagingSenderId: '495828605007',
    projectId: 'reddit-clone-b8463',
    storageBucket: 'reddit-clone-b8463.appspot.com',
    androidClientId: '495828605007-ofgia2b0hboa167grnhcl0d19pl0sfig.apps.googleusercontent.com',
    iosClientId: '495828605007-r5u2dmeih18p3mrms02najj75t4fvfli.apps.googleusercontent.com',
    iosBundleId: 'com.example.redditClone2',
  );

}