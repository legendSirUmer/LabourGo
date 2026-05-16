import 'package:flutter/material.dart';

class BookingManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Management'),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with dynamic booking count from backend
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Booking #$index'), // Replace with booking data
              subtitle: Text('Status: Pending'), // Replace with booking status
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      // Approve booking
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      // Reject booking
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}