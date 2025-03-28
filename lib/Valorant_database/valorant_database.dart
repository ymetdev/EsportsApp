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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Valorant Database Page'), // แสดงข้อความแนะนำ
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamsPage(teams: teams),
                          ),
                        );
                      },
                      child: Text('Teams'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayersPage(players: players),
                          ),
                        );
                      },
                      child: Text('Players'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // ไปที่หน้าที่เกี่ยวกับ Matches
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchesPage(matches: matches),
                          ),
                        );
                      },
                      child: Text('Matches'),
                    ),
                  ],
                ),
      ),
    );
  }
}
