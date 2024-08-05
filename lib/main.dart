import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:men_matter_too/firebase_options.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/screens/edit_profile.dart';
import 'package:men_matter_too/screens/home_screen.dart';
import 'package:men_matter_too/screens/login_screen.dart';
import 'package:men_matter_too/screens/profile_page.dart';
import 'package:men_matter_too/screens/search_page.dart';
import 'package:men_matter_too/screens/signup_screen.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Future.delayed(
    const Duration(milliseconds: 1500),
    () => FlutterNativeSplash.remove(),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.photos,
      Permission.camera,
      Permission.mediaLibrary,
    ].request();

    if (statuses[Permission.camera]?.isGranted ?? false) {
      return true;
    } else {
      showSnackbar(
        context,
        'Please grant permissions to proceed.',
        type: TypeOfSnackbar.success,
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Men Matter Too',
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
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfilePage(),
          '/search': (context) => const SearchPage(),
          '/edit': (context) => const EditProfile(),
        },
        home: Scaffold(
          body: StreamBuilder(
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
              if (snapshot.hasData || snapshot.data != null) {
                Provider.of<UserProvider>(context)
                    .getAndSetUser(snapshot.data!.uid);
                return const Center(
                  child: HomeScreen(),
                );
              }
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
