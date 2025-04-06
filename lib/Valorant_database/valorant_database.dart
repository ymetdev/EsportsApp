import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'teams.dart';
import 'players.dart';
import 'matches.dart';
import '../custom_page_route.dart';

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
      backgroundColor: Color(0xFF101010), // สีพื้นหลัง
      appBar: AppBar(
        backgroundColor: Color(0xFFA12C2C),
        title: Text(
          'Valorant Database',
          style: TextStyle(color: Colors.white), // สีข้อความบน AppBar
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ), // สีของปุ่ม back หรือ icons
        elevation: 0,
      ),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator(color: Color(0xFFA12C2C)) // สีโหลด
                : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 35),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ), // เพิ่ม padding x
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valorant Database Page',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA12C2C),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Explore all the detailed statistics and player data.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Button - Teams
                    _buildButton(
                      label: "Teams",
                      icon: Icons.group,
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: TeamsPage(teams: teams)),
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    // Button - Players
                    _buildButton(
                      label: "Players",
                      icon: Icons.person,
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: PlayersPage(players: players)),
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    // Button - Matches
                    _buildButton(
                      label: "Matches",
                      icon: Icons.sports_esports,
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: MatchesPage(matches: matches)),
                        );
                      },
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 60),
          backgroundColor: Colors.white, // พื้นหลังปุ่มเป็นขาว
          foregroundColor: Color(0xFFA12C2C), // สีเมื่อกดปุ่ม
          elevation: 5,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF101010), // สีตัวหนังสือ
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Icon(icon, color: Color(0xFFA12C2C)),
          ],
        ),
      ),
    );
  }
}
