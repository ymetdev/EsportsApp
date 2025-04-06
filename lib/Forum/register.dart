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
    // ตรวจสอบว่าผู้ใช้กรอกข้อมูลครบถ้วนหรือไม่
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in all fields!')));
      return; // ถ้ายังไม่กรอกครบ ให้หยุดการทำงาน
    }

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
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Color(0xFFa12c2c), // สีแดงเข้มสำหรับ AppBar
        foregroundColor: Colors.white, // สีขาวสำหรับข้อความใน AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          // ตั้งค่าตัวอักษรเริ่มต้นชิดซ้าย
          children: <Widget>[
            SizedBox(height: 45),
            // เพิ่มการแสดงโลโก้ที่ด้านบน
            Align(
              alignment: Alignment.topCenter, // ตั้งโลโก้ให้ชิดด้านบน
              child: Image.asset(
                'icon.png',
                height: 200, // ปรับขนาดโลโก้ตามต้องการ
              ),
            ),

            SizedBox(height: 45),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                  color: Colors.white,
                ), // ข้อความ label สีขาว
                filled: true,
                fillColor: Color(0xFF101010), // พื้นหลังของ TextField เป็นสีดำ
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color(0xFFa12c2c)),
                ),
              ),
              style: TextStyle(color: Colors.white),
              cursorColor: Color(0xFFa12c2c),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF101010),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color(0xFFa12c2c)),
                ),
              ),
              style: TextStyle(color: Colors.white),
              cursorColor: Color(0xFFa12c2c),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF101010),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color(0xFFa12c2c)),
                ),
              ),
              style: TextStyle(color: Colors.white),
              cursorColor: Color(0xFFa12c2c),
              obscureText: true, // ซ่อนรหัสผ่าน
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity, // ให้ปุ่มยาวเต็มความกว้าง
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFa12c2c), // สีแดงเข้มสำหรับปุ่ม
                    foregroundColor: Colors.white, // สีข้อความในปุ่มเป็นสีขาว
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text('Register'),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF101010), // พื้นหลังของทั้งหน้าเป็นสีดำ
    );
  }
}
