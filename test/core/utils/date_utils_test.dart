import 'package:easy_todo/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskDateUtils', () {
    group('isToday', () {
      test('returns true for today', () {
        final now = DateTime.now();
        expect(TaskDateUtils.isToday(now), isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(TaskDateUtils.isToday(yesterday), isFalse);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(TaskDateUtils.isToday(tomorrow), isFalse);
      });

      test('returns true for today at different times', () {
        final now = DateTime.now();
        final todayMorning = DateTime(now.year, now.month, now.day, 0, 0, 1);
        final todayNight = DateTime(now.year, now.month, now.day, 23, 59, 59);
        expect(TaskDateUtils.isToday(todayMorning), isTrue);
        expect(TaskDateUtils.isToday(todayNight), isTrue);
      });
    });

    group('isFuture', () {
      test('returns true for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(TaskDateUtils.isFuture(tomorrow), isTrue);
      });

      test('returns false for today', () {
        final today = DateTime.now();
        expect(TaskDateUtils.isFuture(today), isFalse);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(TaskDateUtils.isFuture(yesterday), isFalse);
      });

      test('returns true for next week', () {
        final nextWeek = DateTime.now().add(const Duration(days: 7));
        expect(TaskDateUtils.isFuture(nextWeek), isTrue);
      });
    });

    group('isSameDay', () {
      test('returns true for same day different time', () {
        final d1 = DateTime(2024, 1, 15, 8, 0);
        final d2 = DateTime(2024, 1, 15, 20, 0);
        expect(TaskDateUtils.isSameDay(d1, d2), isTrue);
      });

      test('returns false for different days', () {
        final d1 = DateTime(2024, 1, 15);
        final d2 = DateTime(2024, 1, 16);
        expect(TaskDateUtils.isSameDay(d1, d2), isFalse);
      });

      test('returns false for same day different month', () {
        final d1 = DateTime(2024, 1, 15);
        final d2 = DateTime(2024, 2, 15);
        expect(TaskDateUtils.isSameDay(d1, d2), isFalse);
      });

      test('returns false for same day different year', () {
        final d1 = DateTime(2023, 1, 15);
        final d2 = DateTime(2024, 1, 15);
        expect(TaskDateUtils.isSameDay(d1, d2), isFalse);
      });
    });

    group('isPast', () {
      test('returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(TaskDateUtils.isPast(yesterday), isTrue);
      });

      test('returns false for today', () {
        final today = DateTime.now();
        expect(TaskDateUtils.isPast(today), isFalse);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(TaskDateUtils.isPast(tomorrow), isFalse);
      });
    });
  });
}
