import 'package:cloud_firestore/cloud_firestore.dart';

class CalvingHistory {
  final DateTime date;
  final String calvingCourse;
  final String calfCount;

  CalvingHistory({required this.date, required this.calvingCourse, required this.calfCount});

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'calvingCourse': calvingCourse,
      'calfCount': calfCount,
    };
  }
}