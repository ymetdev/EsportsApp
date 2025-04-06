import 'package:flutter/material.dart';
import 'login.dart'; // นำเข้าไฟล์ login.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      debugShowCheckedModeBanner: false, // ปิด debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          // กำหนดฟอนต์ให้กับข้อความต่าง ๆ
          displayLarge: TextStyle(fontFamily: 'MyCustomFont'),
          displayMedium: TextStyle(fontFamily: 'MyCustomFont'),
          displaySmall: TextStyle(fontFamily: 'MyCustomFont'),
          headlineMedium: TextStyle(fontFamily: 'MyCustomFont'),
          headlineSmall: TextStyle(fontFamily: 'MyCustomFont'),
          titleLarge: TextStyle(fontFamily: 'MyCustomFont'),
          titleMedium: TextStyle(fontFamily: 'MyCustomFont'),
          titleSmall: TextStyle(fontFamily: 'MyCustomFont'),
          bodyLarge: TextStyle(fontFamily: 'MyCustomFont'),
          bodyMedium: TextStyle(fontFamily: 'MyCustomFont'),
          bodySmall: TextStyle(fontFamily: 'MyCustomFont'),
          labelLarge: TextStyle(fontFamily: 'MyCustomFont'),
          labelMedium: TextStyle(fontFamily: 'MyCustomFont'),
          labelSmall: TextStyle(fontFamily: 'MyCustomFont'),
        ),
      ),
      home: LoginPage(), // กำหนดหน้าเริ่มต้นเป็น LoginPage
    );
  }
}
