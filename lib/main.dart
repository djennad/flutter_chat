import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_web_app/screens/auth_screen.dart';
import 'package:chat_web_app/screens/chat_screen.dart';
import 'package:chat_web_app/screens/users_screen.dart';
import 'package:chat_web_app/providers/auth_provider.dart' as app_auth;
import 'package:provider/provider.dart';
import 'package:chat_web_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAWdy3w-CNr1721Gi9GmJbzJzGmlUod_Wk",
      authDomain: "test-1f4db.firebaseapp.com",
      projectId: "test-1f4db",
      storageBucket: "test-1f4db.appspot.com",
      messagingSenderId: "1040716817417",
      appId: "1:1040716817417:web:e33bcca17c6383dfa5c4d8"
    )
  );
  await NotificationService.initialize();
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData) {
              return const ChatScreen();
            }
            return const AuthScreen();
          },
        ),
        routes: {
          '/users': (ctx) => const UsersScreen(),
        },
      ),
    );
  }
}
