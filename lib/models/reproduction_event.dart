import 'package:cloud_firestore/cloud_firestore.dart';

enum ReproEventType { besamung, brunst, kalbung, trockenstellen }

class ReproductionEvent {
  final String id;
  final ReproEventType type;
  final DateTime date;
  final bool? success;
  final String note;
  final DateTime? nextExpectedHeat;
  final DateTime? expectedCalvingDate;

  ReproductionEvent({
    required this.id,
    required this.type,
    required this.date,
    this.success,
    this.note = '',
    this.nextExpectedHeat,
    this.expectedCalvingDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'date': Timestamp.fromDate(date),
      'success': success,
      'note': note,
      'nextExpectedHeat': nextExpectedHeat != null
          ? Timestamp.fromDate(nextExpectedHeat!)
          : null,
      'expectedCalvingDate': expectedCalvingDate != null
          ? Timestamp.fromDate(expectedCalvingDate!)
          : null,
    };
  }

  factory ReproductionEvent.fromMap(String id, Map<String, dynamic> map) {
    return ReproductionEvent(
      id: id,
      type: ReproEventType.values.byName(map['type']),
      date: (map['date'] as Timestamp).toDate(),
      success: map['success'],
      note: map['note'] ?? '',
      nextExpectedHeat: (map['nextExpectedHeat'] as Timestamp?)?.toDate(),
      expectedCalvingDate: (map['expectedCalvingDate'] as Timestamp?)?.toDate(),
    );
  }
}
