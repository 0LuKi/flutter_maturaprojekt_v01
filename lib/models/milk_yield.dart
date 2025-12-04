import 'package:cloud_firestore/cloud_firestore.dart';

class MilkYield {
  final DateTime date;
  final double amountLiters;
  final String session;
  
  MilkYield({required this.date, required this.amountLiters, required this.session});

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'amountLiters': amountLiters,
      'session': session,
    };
  }
}