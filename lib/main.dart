import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'providers/app_state.dart';
import 'providers/sensor_provider.dart';
import 'providers/history_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_dashboard.dart';
import 'services/dummy_data_seeder.dart';
import 'services/firebase_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  // Seed dummy data on first launch (don't block runApp)
  print('Checking if dummy data needs to be seeded...');
  DummyDataSeeder.instance.seedAll().then((_) {
    print('Dummy data seed check complete.');
  }).catchError((e) {
    print('Error seeding dummy data: $e');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => SensorProvider()..startListening()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const AgroPilotApp(),
    ),
  );
}

class AgroPilotApp extends StatelessWidget {
  const AgroPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroPilot AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          final user = snapshot.data!;
          // Trigger loading of user data if not already loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final appState = context.read<AppState>();
            if (appState.profile == null) {
              appState.loadFromFirebase(user.email ?? '');
              context.read<HistoryProvider>().loadAll();
            }
          });
          return const HomeDashboard();
        }
        
        return const LoginScreen();
      },
    );
  }
}
