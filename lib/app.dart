import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

class HvacCalcApp extends StatefulWidget {
  const HvacCalcApp({super.key});

  // Статичний ключ для перемикання теми з будь-якого місця
  static final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  State<HvacCalcApp> createState() => _HvacCalcAppState();
}

class _HvacCalcAppState extends State<HvacCalcApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: HvacCalcApp.themeNotifier,
      builder: (_, mode, _) => MaterialApp(
        title: 'HVAC Calc Pro',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme:     AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const HomeScreen(),
      ),
    );
  }
}
