class ReproductionCalculator {
  static const int heatCycleDays = 21;
  static const int gestationDays = 280;
  static const int dryOffDaysBeforeCalving = 60;

  static DateTime calculateNextHeat(DateTime lastEventDate) {
    return lastEventDate.add(const Duration(days: heatCycleDays));
  }

  static DateTime calculateExpectedCalving(DateTime inseminationDate) {
    return inseminationDate.add(const Duration(days: gestationDays));
  }

  static DateTime calculateDryOffDate(DateTime expectedCalvingDate) {
    return expectedCalvingDate.subtract(
      const Duration(days: dryOffDaysBeforeCalving),
    );
  }

  static String mapStatusToGerman(String status) {
    switch (status) {
      case 'offen':
        return 'Offen (Bereit)';
      case 'belegt':
        return 'Belegt (Warten)';
      case 'traechtig':
        return 'Trächtig';
      case 'trocken':
        return 'Trockengestellt';
      default:
        return 'Unbekannt';
    }
  }
}
