import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/movie_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.red,
          unselectedItemColor: Color.fromARGB(179, 255, 255, 255),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/movies': (context) => const MovieHomeScreen(),
      },
    );
  }
}
