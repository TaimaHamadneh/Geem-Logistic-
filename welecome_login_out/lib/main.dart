import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:welecome_login_out/Welcome/welcome.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future BackgroundMessage(RemoteMessage message) async {
  print('*****************Notification-BackgroundMessage****************');
  if (message.notification != null) {
    print('Title: ${message.notification!.title}');
    print('Body: ${message.notification!.body}');
   
  }
  if (message.data.isNotEmpty) {
    print('Data Payload: ${message.data}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final fbm = FirebaseMessaging.instance;
  await fbm.requestPermission();
  
  FirebaseMessaging.onBackgroundMessage(BackgroundMessage);

  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _currentLocale = const Locale('en');

  @override
  void initState() {
    super.initState();
  }

  void _toggleLanguage() {
    setState(() {
      if (_currentLocale.languageCode == 'en') {
        _currentLocale = const Locale('ar');
      } else {
        _currentLocale = const Locale('en');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _currentLocale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      home: Scaffold( //kIsWeb ? WelcomeWebPage():
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: WelcomePage(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 300,
                child:  IconButton(
            onPressed: _toggleLanguage,
            icon: Image.asset(
              _currentLocale.languageCode == 'en'
                  ? 'assets/images/sudia.png'
                  : 'assets/images/us.png',
              width: 50,
              height: 50,
            ),
          ),
       
              ),
            ),
          ],
        ),
      ),
    );
  } 
      
  

  ThemeData _buildThemeData() {
    return ThemeData(
      primaryColor: Approved.PrimaryColor,
      scaffoldBackgroundColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: Approved.PrimaryColor,
          shape: const StadiumBorder(),
          maximumSize: const Size(double.infinity, 56),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Approved.LightColor,
        iconColor: Approved.PrimaryColor,
        prefixIconColor: Approved.PrimaryColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Approved.defaultPadding,
          vertical: Approved.defaultPadding,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}



