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
        body: CharacterGrid(),
      ),
    );
  }
}

class CharacterGrid extends StatefulWidget {
  @override
  _CharacterGridState createState() => _CharacterGridState();
}

class _CharacterGridState extends State<CharacterGrid> {
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
        : GridView.builder(
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
            height: 50,
            width: 50,
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
