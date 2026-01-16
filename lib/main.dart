import 'dart:math';

import 'package:flutter/material.dart';
import 'package:object_box_poc/core/cache/manager/objectbox_manager.dart';
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
    return const MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: TextButton(
              onPressed: () {
                ObjectboxManager.instance.save();
              },
              child: Text('Save'),
            ),
          ),
          TextButton(
            onPressed: () {
              ObjectboxManager.instance.get();
            },
            child: Text('Get'),
          ),
          TextButton(
            onPressed: () {
              ObjectboxManager.instance.update(
                1,
                'Updated Name ${Random().nextInt(100)}',
              );
            },
            child: Text('Update'),
          ),

          TextButton(
            child: Text('Delete'),
            onPressed: () {
              ObjectboxManager.instance.delete(1);
            },
          ),
          TextButton(
            child: Text('Remove All'),
            onPressed: () {
              ObjectboxManager.instance.removeAll();
            },
          ),
        ],
      ),
    );
  }
}
