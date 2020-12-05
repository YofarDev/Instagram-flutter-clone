import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/res/constants.dart';
import 'package:instagram_clone/services/database/authentication_services.dart';
import 'package:instagram_clone/ui/pages/login/login_page.dart';
import 'package:instagram_clone/ui/pages_holder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance),
          ),
          StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
          )
        ],
        child: MaterialApp(
          theme: ThemeData(
            backgroundColor: Colors.white,
          ),
          home: AuthenticationWrapper(),
          debugShowCheckedModeBanner: false,
        ));
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if (firebaseUser != null) {
      _saveStatusBarHeight(context);
      return PagesHolder(0,darkTheme: false);
    }
    return LoginPage();
  }

  void _saveStatusBarHeight(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
        Constants.KEY_STATUS_BAR_HEIGHT, MediaQuery.of(context).padding.top);
  }
}
