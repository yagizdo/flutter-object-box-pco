import 'package:flutter/material.dart';
import 'package:object_box_poc/core/manager/objectbox_manager.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

Future<void> main() async {
  /// This is required to initialize the Flutter binding
  /// So ObjectBox can get the application directory to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  /// This is a workaround to load the ObjectBox library on Android 6 and older
  loadObjectBoxLibraryAndroidCompat();

  await ObjectboxManager.create();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
