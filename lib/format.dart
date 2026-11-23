/// Deutsche Datums- und Zeitangaben ohne Zusatzpaket.
const _tage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const _monate = ['Jan.', 'Feb.', 'März', 'Apr.', 'Mai', 'Juni', 'Juli', 'Aug.', 'Sep.', 'Okt.', 'Nov.', 'Dez.'];

String zwei(int n) => n.toString().padLeft(2, '0');

/// „Fr 20. Nov.“
String tagKurz(DateTime d) => '${_tage[d.weekday - 1]} ${d.day}. ${_monate[d.month - 1]}';

/// „Fr 20. Nov., 21:38 Uhr“
String tagUndZeit(DateTime d) => '${tagKurz(d)}, ${zwei(d.hour)}:${zwei(d.minute)} Uhr';

/// „34 Min.“
String dauer(int sekunden) {
  if (sekunden <= 0) return '';
  final m = (sekunden / 60).round();
  return m < 60 ? '$m Min.' : '${m ~/ 60} Std. ${zwei(m % 60)} Min.';
}

/// „1:05“ bzw. „1:02:03“ für den Spieler.
String laufzeit(Duration d) {
  final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
  return h > 0 ? '$h:${zwei(m)}:${zwei(s)}' : '$m:${zwei(s)}';
}
