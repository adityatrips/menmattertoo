import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/auth_state_home_page.dart';
import 'package:men_matter_too/firebase_options.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: const ColorScheme.dark().copyWith(
            primary: Colors.blue.shade700,
            secondary: Colors.grey.shade700,
            tertiary: const Color(0xFF111111),
          ),
          scaffoldBackgroundColor: Colors.black,
          brightness: Brightness.dark,
          fontFamily: 'DMSans',
          iconTheme: IconThemeData(color: Colors.blue.shade700),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.blue.shade900),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (snapshot.hasData) {
              return const AuthStateHomePage();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}