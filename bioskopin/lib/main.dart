import 'package:bioskopin/screens/splash_screen.dart';
import 'package:bioskopin/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: appBarTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF277FBF),
    ),
    useMaterial3: true,
    fontFamily: 'Poppins',
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    scrolledUnderElevation: 0.0,
    shape: Border(
      bottom: BorderSide(
        width: 1.0,
        color: Color.fromRGBO(224, 224, 224, 1),
      ),
    ),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20.0,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
    ),
    centerTitle: true,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferencesService = SharedPreferencesService();
  await sharedPreferencesService.init();

  await initializeDateFormatting('id_ID', null).then(
    (_) => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bioskopin',
      theme: theme(),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
