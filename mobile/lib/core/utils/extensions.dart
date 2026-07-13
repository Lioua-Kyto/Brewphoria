import 'package:intl/intl.dart';

extension StringExtension on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');

  bool get isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  String truncate(int maxLength, {String ellipsis = '...'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';
}

extension NumExtension on num {
  String get toCurrency => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(this);
  String get toPoints => NumberFormat('#,##0').format(this);
}

extension DoubleExtension on double {
  String get toCurrency => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(this);
}

extension DateTimeExtension on DateTime {
  String get toDisplayDate => DateFormat('MMM dd, yyyy').format(this);
  String get toDisplayDateTime => DateFormat('MMM dd, yyyy • hh:mm a').format(this);
  String get toRelative {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return toDisplayDate;
  }
}
