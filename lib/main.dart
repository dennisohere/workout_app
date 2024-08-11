import 'package:flutter/material.dart';
import 'package:gainz/app.dart';
import 'package:gainz/utils/di/injector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Injector.setup();

  runApp(const App());
}


