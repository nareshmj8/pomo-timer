class StatisticsData {
  final Map<String, Map<String, List<double>>> data;

  StatisticsData({required this.data});

  static StatisticsData defaultData() {
    return StatisticsData(data: {
      'Daily': {
        'hours': [2.5, 3.0, 2.8, 3.5, 2.0, 1.5, 4.0],
        'sessions': [3.0, 2.0, 3.0, 4.0, 2.0, 1.0, 5.0],
      },
      'Weekly': {
        'hours': [15.0, 14.5, 16.0, 13.5, 15.5, 14.0, 16.5],
        'sessions': [12.0, 11.0, 13.0, 10.0, 12.0, 11.0, 14.0],
      },
      'Monthly': {
        'hours': [45.5, 48.0, 42.5, 50.0, 47.5, 46.0, 49.0],
        'sessions': [35.0, 38.0, 33.0, 40.0, 37.0, 36.0, 39.0],
      },
      'Total': {
        'hours': [120.0],
        'sessions': [90.0],
      },
    });
  }
}
