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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBawLk7FXo_JLkHn2DAsvPq7jJ65oFxit4',
    appId: '1:334593508928:web:87b14b8748c11105cd01a5',
    messagingSenderId: '334593508928',
    projectId: 'event-master-2bf93',
    authDomain: 'event-master-2bf93.firebaseapp.com',
    databaseURL: 'https://event-master-2bf93-default-rtdb.firebaseio.com',
    storageBucket: 'event-master-2bf93.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsmz6muR2iWyQFx_iL43roclqFhbW07-Y',
    appId: '1:334593508928:android:0c37b74274fd0de8cd01a5',
    messagingSenderId: '334593508928',
    projectId: 'event-master-2bf93',
    databaseURL: 'https://event-master-2bf93-default-rtdb.firebaseio.com',
    storageBucket: 'event-master-2bf93.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQnP4X5kalPbXNiBmAahI0TkLNK9zH7rQ',
    appId: '1:334593508928:ios:243d1725fd58612ccd01a5',
    messagingSenderId: '334593508928',
    projectId: 'event-master-2bf93',
    databaseURL: 'https://event-master-2bf93-default-rtdb.firebaseio.com',
    storageBucket: 'event-master-2bf93.appspot.com',
    androidClientId: '334593508928-b49laga5iqbih3v4takm8jbp7dheocli.apps.googleusercontent.com',
    iosClientId: '334593508928-4tscr6nn0t4nqen2h76epdqikfjm3dff.apps.googleusercontent.com',
    iosBundleId: 'com.example.eventMaster',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQnP4X5kalPbXNiBmAahI0TkLNK9zH7rQ',
    appId: '1:334593508928:ios:243d1725fd58612ccd01a5',
    messagingSenderId: '334593508928',
    projectId: 'event-master-2bf93',
    databaseURL: 'https://event-master-2bf93-default-rtdb.firebaseio.com',
    storageBucket: 'event-master-2bf93.appspot.com',
    androidClientId: '334593508928-b49laga5iqbih3v4takm8jbp7dheocli.apps.googleusercontent.com',
    iosClientId: '334593508928-4tscr6nn0t4nqen2h76epdqikfjm3dff.apps.googleusercontent.com',
    iosBundleId: 'com.example.eventMaster',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBawLk7FXo_JLkHn2DAsvPq7jJ65oFxit4',
    appId: '1:334593508928:web:d63d8f2f8efcf50ccd01a5',
    messagingSenderId: '334593508928',
    projectId: 'event-master-2bf93',
    authDomain: 'event-master-2bf93.firebaseapp.com',
    databaseURL: 'https://event-master-2bf93-default-rtdb.firebaseio.com',
    storageBucket: 'event-master-2bf93.appspot.com',
  );
}
