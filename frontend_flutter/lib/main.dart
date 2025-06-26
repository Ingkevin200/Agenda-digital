import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Event {
  final int id;
  final String title;
  final String date;

  Event({required this.id, required this.title, required this.date});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      date: json['date'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Digital',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: EventListScreen(),
    );
  }
}

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _controller = TextEditingController();
  final _dateController = TextEditingController();
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final response = await http.get(Uri.parse('http://localhost:8085/events'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        events = data.map((e) => Event.fromJson(e)).toList();
      });
    }
  }

  Future<void> createEvent(String title, String date) async {
    final response = await http.post(
      Uri.parse('http://localhost:8085/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'date': date}),
    );

    if (response.statusCode == 201) {
      _controller.clear();
      _dateController.clear();
      fetchEvents(); // Refresca la lista
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📅 Agenda Digital')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Título del evento'),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty && _dateController.text.isNotEmpty) {
                  createEvent(_controller.text, _dateController.text);
                }
              },
              child: Text('Agregar evento'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (_, index) {
                  final e = events[index];
                  return ListTile(
                    title: Text(e.title),
                    subtitle: Text('📅 ${e.date}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
