import 'package:flutter/material.dart';

class StatCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;

  const StatCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Stack(
        children: [
          Positioned(right: 0, top: 0,
            child: Icon(icon, size: 32, color: color.withOpacity(0.2))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8))),
              Text(value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: color)),
              Text(change,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }
}