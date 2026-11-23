import 'package:flutter_test/flutter_test.dart';
import 'package:kurszettel/format.dart';

void main() {
  test('Datum und Dauer auf Deutsch', () {
    expect(tagKurz(DateTime(2026, 11, 20)), 'Fr 20. Nov.');
    expect(dauer(2042), '34 Min.');
    expect(dauer(4000), '1 Std. 07 Min.');
    expect(laufzeit(const Duration(minutes: 1, seconds: 5)), '1:05');
  });
}
