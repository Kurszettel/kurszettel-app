# Kurszettel-App

App zum Podcast **Kurszettel** (kurszettel.com) für Android und iOS: Podcast-Folgen hören, Börsentermine mit Filter und Kalender-Übernahme, Kurzmeldungen mit Vorlesen.

## Aufbau

| Pfad | Inhalt |
|---|---|
| `lib/api.dart` | Zugriff auf die Schnittstelle `https://kurszettel.com/api` (Folgen, Termine, News) |
| `lib/screens/` | Die vier Bereiche: Folgen, Termine, News, Info |
| `lib/player.dart` | Gemeinsamer Audio-Spieler (just_audio) mit Mini-Leiste |
| `lib/format.dart` | Deutsche Datums- und Zeitangaben |
| `.github/workflows/android.yml` | Automatischer Bau bei jedem Push auf `main` |

Die Schnittstelle liegt auf dem Webserver (`public_html/api/index.php`) und ist in der Projektnotiz `app-schnittstelle.md` beschrieben. Die App speichert keine Nutzerdaten außer der Terminauswahl auf dem Gerät.

## Bauen

Kein lokaler Rechner nötig: Jeder Push auf `main` startet den Bau bei GitHub Actions (Flutter stable, Java 17). Ablauf:

1. Beim ersten Lauf erzeugt `flutter create` die Ordner `android/` und `ios/` und schreibt sie zurück ins Repository.
2. `flutter analyze`, `flutter test`, `flutter build apk --release`.
3. Die APK wird als Vorabversion **„test-latest“** unter *Releases* abgelegt (mit SHA-256-Prüfsumme).

Lokal (falls jemand übernimmt): Flutter stable installieren, dann `flutter pub get` und `flutter run`.

## Kennungen

- Android: `com.kurszettel.app` (in `android/app/build.gradle.kts`) – **nach der ersten Store-Veröffentlichung nicht mehr ändern.**
- Mindestversionen: Android 7 (API 24), iOS 15.

## Stand

- Testfassung Android: mit dem Debug-Schlüssel signiert, nur zum Ausprobieren. Für Website- und Store-Verteilung kommt ein eigener Signierschlüssel (Geheimnisse im Repository-Bereich *Settings → Secrets*, nie im Code).
- iOS: Code ist gemeinsam; Bau und Test erst mit dem Apple-Entwicklerkonto der Kurszettel GmbH (Codemagic oder TestFlight).
- Noch nicht drin: Wiedergabe mit Sperrbildschirm-Steuerung, Hinweis auf neue Version, App-Symbol.

Verantwortlich: Steffen Reukauf, podcast@kurszettel.com. Code wird von Claude (Anthropic) geschrieben und gepflegt.
