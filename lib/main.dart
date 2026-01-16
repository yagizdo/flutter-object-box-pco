import 'package:flutter/material.dart';
import 'package:object_box_poc/core/cache/manager/objectbox_manager.dart';
import 'package:object_box_poc/screens/home_screen.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

Future<void> main() async {
  /// This is required to initialize the Flutter binding
  /// So ObjectBox can get the application directory to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  /// This is a workaround to load the ObjectBox library on Android 6 and older
  loadObjectBoxLibraryAndroidCompat();

  await ObjectboxManager.instance.create();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ObjectBox PoC Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
