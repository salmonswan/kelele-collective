import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyASocqnzvKo-kXjbmWgkBuRPhD4Hn5sIhQ',
    appId: '1:155022503410:web:6e9e8358b0d8d4d7bb8f6b',
    messagingSenderId: '155022503410',
    projectId: 'kelele-genius',
    authDomain: 'kelele-genius.firebaseapp.com',
    storageBucket: 'kelele-genius.firebasestorage.app',
  );
}
