import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/onboarding.dart';
import 'screens/shell.dart';
import 'state.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await appState.load();
  runApp(const FitMatchApp());
}

class FitMatchApp extends StatelessWidget {
  const FitMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kMorado),
        scaffoldBackgroundColor: kFondo,
        appBarTheme: const AppBarTheme(
          backgroundColor: kFondo,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: ListenableBuilder(
        listenable: appState,
        builder: (context, _) =>
            appState.perfil == null ? const OnboardingScreen() : Shell(),
      ),
    );
  }
}
