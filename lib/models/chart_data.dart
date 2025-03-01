class ChartData {
  final DateTime date;
  final double hours;
  final double sessions;
  final bool isCurrentPeriod;

  ChartData({
    required this.date,
    required this.hours,
    required this.sessions,
    required this.isCurrentPeriod,
  });
}
