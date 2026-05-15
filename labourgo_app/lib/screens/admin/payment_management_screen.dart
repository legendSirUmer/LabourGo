import 'package:flutter/material.dart';

class PaymentManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Management'),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with dynamic payment count from backend
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Payment #$index'), // Replace with payment data
            subtitle: Text('Status: Paid'), // Replace with payment status
            trailing: Icon(Icons.receipt),
          );
        },
      ),
    );
  }
}