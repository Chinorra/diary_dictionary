import 'package:flutter_test/flutter_test.dart';
import 'package:my_dictionary/database/database.dart';
import 'package:my_dictionary/feature/common/diary_date.dart';
import 'package:my_dictionary/feature/home_screen/bloc/home_bloc.dart';
import 'package:my_dictionary/feature/home_screen/bloc/home_event.dart';
import 'package:my_dictionary/feature/home_screen/bloc/home_state.dart';
import 'package:my_dictionary/feature/home_screen/repository/home_repository.dart';

Word _word(String value, DateTime createdAt) => Word(
      id: value.hashCode,
      word: value,
      definition: 'definition of $value',
      example: '',
      partOfSpeech: 'noun',
      category: 'General',
      createdAt: createdAt,
    );

/// Stands in for the database-backed repository so the bloc can be exercised
/// without a real database.
class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository(this.wordsByDay, {this.shouldFail = false});

  /// Keyed by the start of the diary day the words belong to.
  final Map<DateTime, List<Word>> wordsByDay;
  final bool shouldFail;

  final List<DateTime> requestedDates = [];

  @override
  Future<List<Word>> getWordsByDate(DateTime date) async {
    requestedDates.add(date);
    if (shouldFail) throw Exception('database unavailable');
    return wordsByDay[startOfDiaryDay(date)] ?? const [];
  }
}

void main() {
  group('diary date helpers', () {
    test('two timestamps on the same calendar day are the same diary day', () {
      expect(
        isSameDiaryDay(
          DateTime(2026, 9, 12, 9, 0),
          DateTime(2026, 9, 12, 21, 30),
        ),
        isTrue,
      );
    });

    test('timestamps on neighbouring days are different diary days', () {
      expect(
        isSameDiaryDay(
          DateTime(2026, 9, 12, 23, 59),
          DateTime(2026, 9, 13, 0, 1),
        ),
        isFalse,
      );
    });

    test('day bounds cover the whole calendar day', () {
      final date = DateTime(2026, 9, 12, 16, 45);

      expect(startOfDiaryDay(date), DateTime(2026, 9, 12));
      expect(startOfNextDiaryDay(date), DateTime(2026, 9, 13));
    });

    test('the next day rolls over month and year boundaries', () {
      expect(startOfNextDiaryDay(DateTime(2026, 9, 30)), DateTime(2026, 10, 1));
      expect(startOfNextDiaryDay(DateTime(2026, 12, 31)), DateTime(2027, 1, 1));
    });
  });

  group('HomeBloc', () {
    test('loads the words saved today by default', () async {
      final today = DateTime.now();
      final repository = _FakeHomeRepository({
        startOfDiaryDay(today): [
          _word('apple', today),
          _word('banana', today),
        ],
      });
      final bloc = HomeBloc(repository);

      final states = <HomeState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const DiaryDayRequested());
      await Future<void>.delayed(Duration.zero);

      expect(states.first.status, HomeStatus.loading);
      expect(states.last.status, HomeStatus.success);
      expect(states.last.words.map((w) => w.word), ['apple', 'banana']);
      expect(
        isSameDiaryDay(repository.requestedDates.single, today),
        isTrue,
      );

      await subscription.cancel();
      await bloc.close();
    });

    test('reports an empty diary day without an error', () async {
      final bloc = HomeBloc(_FakeHomeRepository(const {}));

      bloc.add(DiaryDayRequested(DateTime(2026, 9, 12)));
      final state = await bloc.stream.firstWhere(
        (state) => !state.isBusy,
      );

      expect(state.status, HomeStatus.success);
      expect(state.words, isEmpty);
      expect(state.hasNoWords, isTrue);
      expect(state.errorMessage, isNull);

      await bloc.close();
    });

    test('surfaces a readable message when loading fails', () async {
      final bloc = HomeBloc(_FakeHomeRepository(const {}, shouldFail: true));

      bloc.add(const DiaryDayRequested());
      final state = await bloc.stream.firstWhere((state) => !state.isBusy);

      expect(state.status, HomeStatus.error);
      expect(state.words, isEmpty);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, isNot(contains('Exception')));

      await bloc.close();
    });

    test('keeps the selected day when reloading it', () async {
      final day = DateTime(2026, 9, 12, 8, 0);
      final repository = _FakeHomeRepository({
        startOfDiaryDay(day): [_word('apple', day)],
      });
      final bloc = HomeBloc(repository);

      bloc.add(DiaryDayRequested(day));
      await bloc.stream.firstWhere((state) => !state.isBusy);

      bloc.add(DiaryDayRequested(bloc.state.date));
      final reloaded = await bloc.stream.firstWhere((state) => !state.isBusy);

      expect(reloaded.date, day);
      expect(repository.requestedDates, [day, day]);

      await bloc.close();
    });
  });
}
