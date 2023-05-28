import 'package:flutter_firebase/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCp668MA3NB8GK8KPZx4N3v7bm17y4lnWk",
        authDomain: "e-commerce-94e6c.firebaseapp.com",
        projectId: "e-commerce-94e6c",
        storageBucket: "e-commerce-94e6c.appspot.com",
        messagingSenderId: "116001222674",
        appId: "1:116001222674:web:d10f0ebf22af3df42e28cb",
        measurementId: "G-8H3CCT9D8Q"
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 0, 255, 13),
      ),
      home: const WidgetTree(),
    );
  }
}