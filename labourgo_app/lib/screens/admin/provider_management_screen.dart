import 'package:flutter/material.dart';

class ProviderManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider Management'),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with dynamic provider count from backend
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Provider #$index'), // Replace with provider data
            subtitle: Text('Status: Active'), // Replace with provider status
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                // Show provider options
              },
            ),
          );
        },
      ),
    );
  }
}