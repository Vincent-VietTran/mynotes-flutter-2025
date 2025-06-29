import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'This is where your notes will be displayed.',
          style: TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to add a new note
          print('Add a new note');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}