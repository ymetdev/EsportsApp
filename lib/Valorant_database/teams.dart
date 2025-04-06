import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../custom_page_route.dart';

class TeamsPage extends StatefulWidget {
  final List<dynamic> teams;

  const TeamsPage({super.key, required this.teams});

  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  late List<dynamic> _filteredTeams;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTeams = widget.teams;
    _searchController.addListener(() {
      _filterTeams(_searchController.text);
    });
  }

  void _filterTeams(String query) {
    final filtered =
        widget.teams.where((team) {
          final name = team['name']?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();

    setState(() {
      _filteredTeams = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Color(0xFFA12C2C),
        title: Text('Teams List', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search Team',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Color(0xFFA12C2C)),
                filled: true,
                fillColor: Color(0xFF202020),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFA12C2C)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFA12C2C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFA12C2C), width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _filteredTeams.isEmpty
                    ? Center(
                      child: Text(
                        'No teams available',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredTeams.length,
                      itemBuilder: (context, index) {
                        final team = _filteredTeams[index];
                        return Card(
                          color: Color(0xFF202020),
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: ListTile(
                            leading:
                                team['img'] != null
                                    ? Image.network(
                                      'https://cors-anywhere.herokuapp.com/' +
                                          team['img'],
                                      width: 50,
                                      height: 50,
                                    )
                                    : Icon(
                                      Icons.sports_esports,
                                      size: 50,
                                      color: Color(0xFFA12C2C),
                                    ),
                            title: Text(
                              team['name'] ?? 'Unknown Team',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              'Region: ${team['country'] ?? 'Unknown'}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                  page: TeamDetailPage(teamId: team['id']),
                                ),
                              );
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

class TeamDetailPage extends StatefulWidget {
  final String teamId;

  const TeamDetailPage({super.key, required this.teamId});

  @override
  _TeamDetailPageState createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  Map<String, dynamic>? teamData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeamData();
  }

  Future<void> _fetchTeamData() async {
    final url = 'https://vlr.orlandomm.net/api/v1/teams/${widget.teamId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          teamData = json.decode(response.body)['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load team data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Color(0xFFA12C2C),
        title: Text(
          teamData?['info']['name'] ?? 'Team Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Color(0xFFA12C2C)),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child:
                          teamData?['info']['logo'] != null
                              ? Image.network(
                                'https://cors-anywhere.herokuapp.com/' +
                                    teamData!['info']['logo'],
                                height: 100,
                              )
                              : Icon(
                                Icons.sports_esports,
                                size: 100,
                                color: Color(0xFFA12C2C),
                              ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tag: ${teamData?['info']['tag'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Players:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    ...?teamData?['players']?.map(
                      (player) => ListTile(
                        leading:
                            player['img'] != null
                                ? Image.network(
                                  'https://cors-anywhere.herokuapp.com/' +
                                      player['img'],
                                  width: 50,
                                  height: 50,
                                )
                                : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFFA12C2C),
                                ),
                        title: Text(
                          player['name'],
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          player['user'],
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Staff:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    ...?teamData?['staff']?.map(
                      (staff) => ListTile(
                        leading:
                            staff['img'] != null
                                ? Image.network(
                                  'https://cors-anywhere.herokuapp.com/' +
                                      staff['img'],
                                  width: 50,
                                  height: 50,
                                )
                                : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFFA12C2C),
                                ),
                        title: Text(
                          staff['name'],
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          staff['tag'],
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
