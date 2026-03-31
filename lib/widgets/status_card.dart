import 'package:flutter/material.dart';
import 'package:onnx_sample_app/models/app_status.dart';

class StatusCard extends StatelessWidget {
  final AppStatus status;
  final String message;

  const StatusCard({
    super.key,
    required this.status,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AppStatus.error => Colors.red,
      AppStatus.completed => Colors.green,
      AppStatus.processing => Colors.orange,
      _ => Colors.blue,
    };

    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}