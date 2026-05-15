import 'package:flutter/material.dart';

class ReviewManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Management'),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with dynamic review count from backend
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Review #$index'), // Replace with review data
            subtitle: Text('Rating: 5/5'), // Replace with review rating
            trailing: Icon(Icons.star),
          );
        },
      ),
    );
  }
}