import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeamsPage extends StatefulWidget {
  final List<dynamic> teams;

  TeamsPage({required this.teams});

  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredTeams = [];

  @override
  void initState() {
    super.initState();
    _filteredTeams = widget.teams;
  }

  void _filterTeams(String query) {
    setState(() {
      _filteredTeams =
          widget.teams
              .where(
                (team) => team['name'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teams List')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Team',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterTeams,
            ),
          ),
          Expanded(
            child:
                _filteredTeams.isEmpty
                    ? Center(child: Text('No teams available'))
                    : ListView.builder(
                      itemCount: _filteredTeams.length,
                      itemBuilder: (context, index) {
                        final team = _filteredTeams[index];
                        return Card(
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
                                    : Icon(Icons.sports_esports, size: 50),
                            title: Text(
                              team['name'] ?? 'Unknown Team',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Region: ${team['country'] ?? 'Unknown'}',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          TeamDetailPage(teamId: team['id']),
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

  TeamDetailPage({required this.teamId});

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
      appBar: AppBar(title: Text(teamData?['info']['name'] ?? 'Team Details')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
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
                                : Icon(Icons.sports_esports, size: 100),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tag: ${teamData?['info']['tag'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Players:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                                  : Icon(Icons.person, size: 50),
                          title: Text(player['name']),
                          subtitle: Text(player['user']),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Staff:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                                  : Icon(Icons.person, size: 50),
                          title: Text(staff['name']),
                          subtitle: Text(staff['tag']),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
