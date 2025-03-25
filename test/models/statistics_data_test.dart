import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/models/statistics_data.dart';

void main() {
  group('StatisticsData', () {
    test('constructor should set the data property correctly', () {
      final Map<String, Map<String, List<double>>> testData = {
        'Daily': {
          'hours': [1.0, 2.0, 3.0],
          'sessions': [2.0, 3.0, 4.0],
        },
        'Weekly': {
          'hours': [10.0, 12.0],
          'sessions': [8.0, 9.0],
        },
      };

      final statisticsData = StatisticsData(data: testData);

      expect(statisticsData.data, equals(testData));
      expect(statisticsData.data['Daily'], equals(testData['Daily']));
      expect(statisticsData.data['Weekly'], equals(testData['Weekly']));
      expect(statisticsData.data['Daily']?['hours'], equals([1.0, 2.0, 3.0]));
      expect(
          statisticsData.data['Daily']?['sessions'], equals([2.0, 3.0, 4.0]));
    });

    test('defaultData should return a StatisticsData with predefined values',
        () {
      final defaultData = StatisticsData.defaultData();

      expect(defaultData, isA<StatisticsData>());
      expect(defaultData.data, isNotNull);
      expect(defaultData.data.keys,
          containsAll(['Daily', 'Weekly', 'Monthly', 'Total']));

      // Check structure for each period
      ['Daily', 'Weekly', 'Monthly', 'Total'].forEach((period) {
        expect(
            defaultData.data[period]?.keys, containsAll(['hours', 'sessions']));
        expect(defaultData.data[period]?['hours'], isA<List<double>>());
        expect(defaultData.data[period]?['sessions'], isA<List<double>>());
      });

      // Check some specific values
      expect(defaultData.data['Daily']?['hours']?.length, equals(7));
      expect(defaultData.data['Weekly']?['hours']?.length, equals(7));
      expect(defaultData.data['Monthly']?['hours']?.length, equals(7));
      expect(defaultData.data['Total']?['hours']?.length, equals(1));

      // Check a specific value
      expect(defaultData.data['Total']?['hours']?[0], equals(120.0));
      expect(defaultData.data['Total']?['sessions']?[0], equals(90.0));
    });
  });
}
