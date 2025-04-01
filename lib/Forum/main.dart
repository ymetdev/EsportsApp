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
      ),
      home: LoginPage(), // กำหนดหน้าเริ่มต้นเป็น LoginPage
    );
  }
}
