import 'package:flutter/material.dart';

import 'screens/onboarding.dart';
import 'screens/shell.dart';
import 'state.dart';
import 'widgets.dart';

/// Último error de Flutter, para mostrarlo en pantalla (útil al probar el APK).
final ValueNotifier<String?> errorEnPantalla = ValueNotifier(null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (d) {
    FlutterError.presentError(d);
    errorEnPantalla.value = d.exceptionAsString();
  };
  ErrorWidget.builder = (d) => Material(
        color: const Color(0xFFFCEBEB),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(d.exceptionAsString(),
              style: const TextStyle(fontSize: 11, color: Color(0xFF791F1F))),
        ),
      );
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
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          child ?? const SizedBox.shrink(),
          ValueListenableBuilder<String?>(
            valueListenable: errorEnPantalla,
            builder: (context, e, _) => e == null
                ? const SizedBox.shrink()
                : Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: const Color(0xFFFCEBEB),
                      child: SafeArea(
                        bottom: false,
                        child: InkWell(
                          onTap: () => errorEnPantalla.value = null,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text('Error (tocá para cerrar):\n$e',
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF791F1F))),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      home: ListenableBuilder(
        listenable: appState,
        builder: (context, _) =>
            appState.perfil == null ? const OnboardingScreen() : Shell(),
      ),
    );
  }
}
