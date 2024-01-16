import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Character {
  final int id;
  final String name;
  final String image;

  Character({required this.id, required this.name, required this.image});

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Rick and Morty Characters'),
        ),
        body: CharacterList(),
      ),
    );
  }
}

class CharacterList extends StatefulWidget {
  @override
  _CharacterListState createState() => _CharacterListState();
}

class _CharacterListState extends State<CharacterList> {
  late List<Character> characters;

  @override
  void initState() {
    super.initState();
    fetchCharacters();
  }

  Future<void> fetchCharacters() async {
    final response =
        await http.get(Uri.parse('https://rickandmortyapi.com/api/character'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Character> fetchedCharacters = (data['results'] as List)
          .map((characterData) => Character.fromJson(characterData))
          .toList();

      setState(() {
        characters = fetchedCharacters;
      });
    } else {
      throw Exception('Failed to load characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return characters == null
        ? Center(child: CircularProgressIndicator())
        : _buildCharacterList();
  }

  Widget _buildCharacterList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Use GridView for web
          return _buildGridView();
        } else {
          // Use ListView for mobile
          return _buildListView();
        }
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        return CharacterCard(character: characters[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: characters.length,
      itemBuilder: (context, index) {
        return CharacterCard(character: characters[index]);
      },
    );
  }
}

class CharacterCard extends StatelessWidget {
  final Character character;

  CharacterCard({required this.character});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            character.image,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8),
          Text(
            character.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
