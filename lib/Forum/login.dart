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

    // ตรวจสอบว่า username หรือ password เป็นค่าว่างหรือไม่
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password')),
      );
      return; // ไม่ทำอะไรเลยถ้าผู้ใช้ยังไม่ได้กรอกข้อมูล
    }

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
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(0xFFa12c2c),
        foregroundColor: Colors.white, // สีแดงเข้มสำหรับ AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // เปลี่ยนให้ข้อความและโลโก้ชิดซ้าย
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
                  // กำหนดกรอบปกติ
                  borderRadius: BorderRadius.circular(8.0), // ทำมุมมนให้กรอบ
                  borderSide: BorderSide(
                    color: Colors.white,
                  ), // กำหนดสีกรอบเป็นสีขาว
                ),
                focusedBorder: OutlineInputBorder(
                  // กำหนดกรอบเมื่อช่องกรอกถูกโฟกัส
                  borderRadius: BorderRadius.circular(8.0), // ทำมุมมนให้กรอบ
                  borderSide: BorderSide(
                    color: Color(0xFFa12c2c),
                  ), // กำหนดกรอบสีแดงเมื่อโฟกัส
                ),
              ),
              style: TextStyle(color: Colors.white), // ข้อความที่พิมพ์เป็นสีขาว
              cursorColor: Color(0xFFa12c2c), // กำหนดสีของตัวพอยเตอร์เป็นสีแดง
            ),

            SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.white,
                ), // ข้อความ label สีขาว
                filled: true,
                fillColor: Color(0xFF101010), // พื้นหลังของ TextField เป็นสีดำ
                border: OutlineInputBorder(
                  // กำหนดกรอบปกติ
                  borderRadius: BorderRadius.circular(8.0), // ทำมุมมนให้กรอบ
                  borderSide: BorderSide(
                    color: Colors.white,
                  ), // กำหนดสีกรอบเป็นสีขาว
                ),
                focusedBorder: OutlineInputBorder(
                  // กำหนดกรอบเมื่อช่องกรอกถูกโฟกัส
                  borderRadius: BorderRadius.circular(8.0), // ทำมุมมนให้กรอบ
                  borderSide: BorderSide(
                    color: Color(0xFFa12c2c),
                  ), // กำหนดกรอบสีแดงเมื่อโฟกัส
                ),
              ),
              style: TextStyle(color: Colors.white), // ข้อความที่พิมพ์เป็นสีขาว
              cursorColor: Color(0xFFa12c2c), // กำหนดสีของตัวพอยเตอร์เป็นสีแดง
            ),

            SizedBox(height: 20), // ขนาดช่องว่างระหว่างช่องกรอกข้อมูลและปุ่ม
            Center(
              // ใช้ Center widget เพื่อให้ปุ่มอยู่กลาง
              child: SizedBox(
                width: double.infinity, // ให้ปุ่มยาวเต็มความกว้าง
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFa12c2c), // สีแดงเข้มสำหรับปุ่ม
                    foregroundColor: Colors.white, // สีข้อความในปุ่มเป็นสีขาว
                    padding: EdgeInsets.symmetric(
                      vertical: 20,
                    ), // เพิ่มความสูงให้ปุ่ม
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        9,
                      ), // ลดความมนของมุม (ตัวเลขเล็กลงเพื่อให้มุมแหลมขึ้น)
                    ),
                  ),
                  child: Text('Login'),
                ),
              ),
            ),

            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // ไปหน้า Register
                Navigator.push(context, CustomPageRoute(page: RegisterPage()));
              },
              child: Text(
                'Don\'t have an account? Register here',
                style: TextStyle(color: Colors.white), // สีข้อความเป็นสีขาว
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF101010), // พื้นหลังของทั้งหน้าเป็นสีดำ
    );
  }
}
