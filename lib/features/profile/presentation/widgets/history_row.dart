import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class HistoryRow extends StatelessWidget {
  final Map<String, dynamic> record;

  const HistoryRow({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final level = record['level'] as int? ?? 0;
    final word = record['word'] as String? ?? '';
    final score = record['score'] as int? ?? 0;
    final result = record['result'] as String? ?? '';
    final createdAt = record['createdAt'] as Timestamp?;
    final date = createdAt?.toDate();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: result == 'win' ? AppColors.success.withOpacity(0.15) : AppColors.danger.withOpacity(0.15),
          child: Icon(
            result == 'win' ? Icons.check_circle : Icons.close,
            color: result == 'win' ? AppColors.success : AppColors.danger,
          ),
        ),
        title: Text(
          'Seviye $level - $word',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: date != null
            ? Text(date.toString().substring(0, 16))
            : const Text('Tarih yok'),
        trailing: Text(
          '$score puan',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
