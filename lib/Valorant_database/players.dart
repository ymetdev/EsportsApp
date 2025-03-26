import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PlayersPage extends StatefulWidget {
  final List<dynamic> players;

  PlayersPage({required this.players});

  @override
  _PlayersPageState createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredPlayers = [];

  @override
  void initState() {
    super.initState();
    _filteredPlayers = widget.players;
  }

  void _filterPlayers(String query) {
    setState(() {
      _filteredPlayers =
          widget.players
              .where(
                (player) => player['name'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  Future<Map<String, dynamic>?> _fetchPlayerDetails(String playerId) async {
    final url = Uri.parse('https://vlr.orlandomm.net/api/v1/players/$playerId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print("Error fetching player details: $e");
    }
    return null;
  }

  Future<String?> _fetchPlayerImage(String playerId) async {
    final url = Uri.parse('https://vlr.orlandomm.net/api/v1/players/$playerId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['info']['img']; // ดึง URL รูป
      }
    } catch (e) {
      print("Error fetching image: $e");
    }
    return null; // ถ้า error ให้ return null
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Players List')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Player',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterPlayers,
            ),
          ),
          Expanded(
            child:
                _filteredPlayers.isEmpty
                    ? Center(child: Text('No players available'))
                    : ListView.builder(
                      itemCount: _filteredPlayers.length,
                      itemBuilder: (context, index) {
                        final player = _filteredPlayers[index];
                        final playerId = player['id'].toString(); // ID ผู้เล่น

                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: ListTile(
                            leading: FutureBuilder<String?>(
                              future: _fetchPlayerImage(playerId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // แสดงโหลด
                                } else if (snapshot.hasData &&
                                    snapshot.data != null) {
                                  return Image.network(
                                    'https://cors-anywhere.herokuapp.com/' +
                                        snapshot.data!,
                                    width: 50,
                                    height: 50,
                                  );
                                } else {
                                  return Icon(
                                    Icons.person,
                                    size: 50,
                                  ); // ไม่มีรูป
                                }
                              },
                            ),
                            title: Text(
                              player['name'] ?? 'Unknown Player',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Team: ${player['teamTag'] ?? 'N/A'}\n'
                              'Country: ${player['country']?.toUpperCase() ?? 'Unknown'}',
                            ),
                            onTap: () async {
                              final playerDetails = await _fetchPlayerDetails(
                                playerId,
                              );
                              if (playerDetails != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PlayerDetailPage(
                                          playerDetails: playerDetails,
                                        ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class PlayerDetailPage extends StatelessWidget {
  final Map<String, dynamic> playerDetails;

  PlayerDetailPage({required this.playerDetails});

  @override
  Widget build(BuildContext context) {
    final playerInfo = playerDetails['info'];
    final teamInfo = playerDetails['team'];

    return Scaffold(
      appBar: AppBar(title: Text(playerInfo['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // จัดแนวตั้ง
            crossAxisAlignment: CrossAxisAlignment.center, // จัดแนวนอน
            children: [
              // รูปภาพของผู้เล่น
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Image.network(
                    'https://cors-anywhere.herokuapp.com/' + playerInfo['img'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // ชื่อผู้เล่น
              Text(
                playerInfo['user'],
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Name: ${playerInfo['name']}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              // ประเทศของผู้เล่น
              Text(
                'Country: ${playerInfo['country']}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 24),

              // ชื่อทีมและโลโก้ของทีมในบรรทัดเดียวกัน
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // จัดแนวนอนให้ข้อมูลตรงกลาง
                crossAxisAlignment:
                    CrossAxisAlignment.center, // จัดให้โลโก้ทีมอยู่กลาง
                children: [
                  Text(
                    'Team: ${teamInfo['name']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://cors-anywhere.herokuapp.com/' + teamInfo['logo'],
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // URL ของทีม
              ElevatedButton(
                onPressed: () {
                  // เปิดลิงก์ทีมในเบราว์เซอร์
                  launch(teamInfo['url']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: Text(
                  'Visit Team Website',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 16),

              // URL ของผู้เล่น
              ElevatedButton(
                onPressed: () {
                  // เปิดลิงก์ผู้เล่นในเบราว์เซอร์
                  launch(playerInfo['url']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: Text(
                  'Visit Player Website',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
