import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  // ฟังก์ชันสำหรับการลงทะเบียน
  Future<void> register() async {
    final url = Uri.parse('http://localhost:3000/users'); // URL ของ API

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
        'email': _emailController.text,
      }),
    );

    if (response.statusCode == 201) {
      // ถ้าสมัครสำเร็จ จะกลับไปที่หน้า Login
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful! Please login.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // ตั้งค่าตัวอักษรเริ่มต้นชิดซ้าย
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
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true, // ซ่อนรหัสผ่าน
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text('Register')),
          ],
        ),
      ),
    );
  }
}
