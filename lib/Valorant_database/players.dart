import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../custom_page_route.dart';

class PlayersPage extends StatefulWidget {
  final List<dynamic> players;

  const PlayersPage({super.key, required this.players});

  @override
  _PlayersPageState createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final TextEditingController _searchController = TextEditingController();
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
      backgroundColor: Color(0xFF101010),
      appBar: AppBar(
        title: Text('Players List'),
        backgroundColor: Color(0xFFA12C2C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search Player',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFA12C2C)),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
              ),
              onChanged: _filterPlayers,
            ),
          ),
          Expanded(
            child:
                _filteredPlayers.isEmpty
                    ? Center(
                      child: Text(
                        'No players available',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredPlayers.length,
                      itemBuilder: (context, index) {
                        final player = _filteredPlayers[index];
                        final playerId = player['id'].toString();

                        return Card(
                          color: Color(0xFF181818),
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
                                  return CircularProgressIndicator(
                                    color: Color(0xFFA12C2C),
                                  );
                                } else if (snapshot.hasData &&
                                    snapshot.data != null) {
                                  return Image.network(
                                    'https://cors-anywhere.herokuapp.com/${snapshot.data!}',
                                    width: 50,
                                    height: 50,
                                  );
                                } else {
                                  return Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white70,
                                  );
                                }
                              },
                            ),
                            title: Text(
                              player['name'] ?? 'Unknown Player',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                            subtitle: Text(
                              'Team: ${player['teamTag'] ?? 'N/A'}\n'
                              'Country: ${player['country']?.toUpperCase() ?? 'Unknown'}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            onTap: () async {
                              final playerDetails = await _fetchPlayerDetails(
                                playerId,
                              );
                              if (playerDetails != null) {
                                Navigator.push(
                                  context,
                                  CustomPageRoute(
                                    page: PlayerDetailPage(
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

  const PlayerDetailPage({super.key, required this.playerDetails});

  @override
  Widget build(BuildContext context) {
    final playerInfo = playerDetails['info'];
    final teamInfo = playerDetails['team'];

    return Scaffold(
      backgroundColor: Color(0xFF101010),
      appBar: AppBar(
        title: Text(playerInfo['name']),
        backgroundColor: Color(0xFFA12C2C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://cors-anywhere.herokuapp.com/' + playerInfo['img'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 24),
              Text(
                playerInfo['user'],
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Name: ${playerInfo['name']}',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 8),
              Text(
                'Country: ${playerInfo['country']}',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Team: ${teamInfo['name']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
              ElevatedButton(
                onPressed: () => launch(teamInfo['url']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA12C2C),
                ),
                child: Text(
                  'Visit Team Website',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => launch(playerInfo['url']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA12C2C),
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
