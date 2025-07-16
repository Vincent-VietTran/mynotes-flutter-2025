import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_item.dart';
import 'package:mynotes/services/auth_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}


class _NotesViewState extends State<NotesView> {
  MenuItem? selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<MenuItem>(
            initialValue: selectedItem,
            onSelected: (MenuItem item) async{
              switch (item) {
                case MenuItem.logOut:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    // Perform logout action
                    await AuthService.firebase().logOut();
                    // Navigate to login view or perform any other action
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
                  log('User logged out: $shouldLogout');
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
                return const [
                  PopupMenuItem<MenuItem>(
                    value: MenuItem.logOut,
                    child: Text('Log Out'),
                  ),
                ];
            } 
          ),
        ],
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
          log('Add a new note');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context, 
    builder: (context){
      return AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Close dialog and return false
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Close dialog and return true
            },
            child: const Text('Log Out'),
          ),
        ],
      );
    },
  ).then((value)=> value ?? false); // Return false if dialog is dismissed without selection (since showdialog returns optional value)
}