import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart'; // นำเข้า HomePage ที่จะไปหลังจาก Login สำเร็จ
import 'register.dart'; // นำเข้าหน้า Register
import '../custom_page_route.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    // ส่งคำขอไปยัง API สำหรับ login
    final response = await http.post(
      Uri.parse('http://localhost:3000/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      Navigator.pushReplacement(
        context,
        CustomPageRoute(page: HomePage(user: responseData['user'])),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${response.body}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // เปลี่ยนให้ข้อความและโลโก้ชิดซ้าย
          children: <Widget>[
            // เพิ่มการแสดงโลโก้ที่ด้านบน
            Align(
              alignment: Alignment.topCenter, // ตั้งโลโก้ให้ชิดด้านบน
              child: Image.asset(
                'icon.png',
                height: 250, // ปรับขนาดโลโก้ตามต้องการ
              ),
            ),

            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // ไปหน้า Register
                Navigator.push(context, CustomPageRoute(page: RegisterPage()));
              },
              child: Text('Don\'t have an account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
