import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'teams.dart';
import 'players.dart';
import 'matches.dart';

class ValorantDatabasePage extends StatefulWidget {
  const ValorantDatabasePage({super.key});

  @override
  _ValorantDatabasePageState createState() => _ValorantDatabasePageState();
}

class _ValorantDatabasePageState extends State<ValorantDatabasePage> {
  // ตัวแปรสำหรับเก็บข้อมูล
  List<dynamic> teams = [];
  List<dynamic> players = [];
  List<dynamic> matches = [];
  bool isLoading = true; // สถานะการโหลดข้อมูล

  // ฟังก์ชันสำหรับโหลดข้อมูลจาก API
  Future<void> _fetchData() async {
    // URL ของ API ทั้งสาม
    final teamUrl = 'https://vlr.orlandomm.net/api/v1/teams?limit=all';
    final playerUrl = 'https://vlr.orlandomm.net/api/v1/players?limit=all';
    final matchUrl = 'https://vlr.orlandomm.net/api/v1/matches?limit=all';

    try {
      // ทำการร้องขอข้อมูลจาก API
      final teamResponse = await http.get(Uri.parse(teamUrl));
      final playerResponse = await http.get(Uri.parse(playerUrl));
      final matchResponse = await http.get(Uri.parse(matchUrl));

      // เช็คสถานะของการร้องขอ
      if (teamResponse.statusCode == 200 &&
          playerResponse.statusCode == 200 &&
          matchResponse.statusCode == 200) {
        // แปลงข้อมูลจาก JSON
        setState(() {
          teams = json.decode(teamResponse.body)['data'];
          players = json.decode(playerResponse.body)['data'];
          matches = json.decode(matchResponse.body)['data'];
          isLoading = false; // อัปเดตสถานะการโหลด
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // ถ้ามีข้อผิดพลาดในการร้องขอ
      print('Error: $e');
      setState(() {
        isLoading = false; // ถ้าเกิดข้อผิดพลาดก็ให้สถานะการโหลดเป็น false
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData(); // โหลดข้อมูลเมื่อเริ่มต้น
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Valorant Database')),
      body: Center(
        child:
            isLoading // เช็คสถานะการโหลด
                ? CircularProgressIndicator() // แสดงตัวโหลดระหว่างที่ยังโหลดข้อมูล
                : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 35),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valorant Database Page',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 8), // เว้นช่องว่างระหว่างสองข้อความ
                        Text(
                          "Explore all the detailed statistics and player data.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54, // สีที่ไม่ฉูดฉาดเกินไป
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // ปุ่ม Teams
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            70,
                          ), // กำหนดให้ปุ่มยาวเต็มจอ
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamsPage(teams: teams),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Teams',
                              style: TextStyle(
                                fontSize: 20, // กำหนดขนาดตัวอักษรเป็น 20
                                color:
                                    Colors
                                        .deepPurple, // สีตัวอักษรเป็น deep purple
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ), // ระยะห่างระหว่างข้อความและไอคอน
                            Icon(
                              Icons.group,
                              color:
                                  Colors.deepPurple, // สีไอคอนเป็น deep purple
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // ปุ่ม Players
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            70,
                          ), // กำหนดให้ปุ่มยาวเต็มจอ
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PlayersPage(players: players),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Players',
                              style: TextStyle(
                                fontSize: 20, // กำหนดขนาดตัวอักษรเป็น 20
                                color:
                                    Colors
                                        .deepPurple, // สีตัวอักษรเป็น deep purple
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ), // ระยะห่างระหว่างข้อความและไอคอน
                            Icon(
                              Icons.person,
                              color:
                                  Colors.deepPurple, // สีไอคอนเป็น deep purple
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // ปุ่ม Matches
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            70,
                          ), // กำหนดให้ปุ่มยาวเต็มจอ
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => MatchesPage(matches: matches),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Matches',
                              style: TextStyle(
                                fontSize: 20, // กำหนดขนาดตัวอักษรเป็น 20
                                color:
                                    Colors
                                        .deepPurple, // สีตัวอักษรเป็น deep purple
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ), // ระยะห่างระหว่างข้อความและไอคอน
                            Icon(
                              Icons.sports_esports,
                              color:
                                  Colors.deepPurple, // สีไอคอนเป็น deep purple
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
