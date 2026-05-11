import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with dynamic user count from backend
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('User #$index'), // Replace with user data
            subtitle: Text('Role: Admin'), // Replace with user role
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit user screen
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add user screen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}