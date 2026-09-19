/// Helpers for the diary day a word belongs to.
///
/// Words are stored with a full timestamp, but the diary groups them by
/// calendar day, so comparisons must always go through these helpers instead
/// of comparing timestamps directly.
DateTime startOfDiaryDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// Start of the day after [date]. Built from the calendar fields so daylight
/// saving transitions cannot shift the boundary.
DateTime startOfNextDiaryDay(DateTime date) =>
    DateTime(date.year, date.month, date.day + 1);

bool isSameDiaryDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// `Sep 19` — used where the year is implied, such as the diary header.
String formatShortDate(DateTime date) =>
    '${_monthNames[date.month - 1]} ${date.day}';

/// `Sep 19, 2026` — used where a word's day is shown on its own.
String formatFullDate(DateTime date) =>
    '${formatShortDate(date)}, ${date.year}';
