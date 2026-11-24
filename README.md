# Kurszettel-App

Kurszettel-App · © 2026 Steffen Reukauf · Lizenz: GPL-3.0-or-later (siehe `LICENSE`).

App zum Podcast **Kurszettel** (kurszettel.com) für Android und iOS: Podcast-Folgen hören, Börsentermine mit Filter und Kalender-Übernahme, Kurzmeldungen mit Vorlesen.

## Aufbau

| Pfad | Inhalt |
|---|---|
| `lib/api.dart` | Zugriff auf die Schnittstelle `https://kurszettel.com/api` (Folgen, Termine, News) |
| `lib/screens/` | Die fünf Bereiche: Heute, News, Termine, Folgen, Einstellungen |
| `lib/player.dart` | Gemeinsamer Audio-Spieler (just_audio) mit Mini-Leiste |
| `lib/format.dart` | Deutsche Datums- und Zeitangaben |
| `.github/workflows/android.yml` | Automatischer Bau bei jedem Push auf `main` |

**Nicht Teil dieses Repositorys und nicht öffentlich:** die Skripte auf dem Server von kurszettel.com (Meldungen, Freigabe, Termine, Schnittstelle). Offen ist nur die App.

Die App liest ihre Inhalte aus der öffentlichen Schnittstelle `https://kurszettel.com/api/` (nur lesend, JSON und Kalenderdateien). Sie braucht kein Konto, enthält keine Werbung und keine Analyse-Bausteine und speichert nur die Terminauswahl auf dem Gerät.

Fertige Fassung zum Laden und Anleitung: https://kurszettel.com/app/

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

- Android: Verteilung über kurszettel.com/app/, später F-Droid und Google Play. Signiert wird im Bau mit einem festen Schlüssel aus den Repository-Geheimnissen (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`); fehlen sie, mit einem Testschlüssel. Schlüssel und Passwort stehen nie im Code.
- iOS: Code ist gemeinsam; Bau und Test folgen mit einem Apple-Entwicklerkonto.
- Gestaltung: Navy, Creme, Gold, Ticks; Schriften Libre Caslon Text (Titel), IBM Plex Mono (Meta), IBM Plex Sans (Text) – OFL-Lizenzen in `assets/fonts`. App-Symbol aus `assets/icon`: nur die beiden Ticks, ohne Schrift.
- Wiedergabe läuft bei gesperrtem Bildschirm weiter (just_audio_background), Steuerung in der Mitteilungsleiste.
- Update-Hinweis: Die App liest das Feld `app` der Schnittstelle und verweist auf die Download-Seite; sie lädt keine ausführbaren Dateien nach.

## Mitmachen

Fehler und Vorschläge bitte als Issue. Die App enthält keine Anlageberatung und keine Empfehlungen zu einzelnen Wertpapieren; Beiträge, die das ändern, werden nicht übernommen.

## Lizenz

Freie Software unter der GNU General Public License, Version 3 oder später (siehe `LICENSE`). „Kurszettel“, die Wort-Bild-Marke und das Logo sind Kennzeichen von Steffen Reukauf (Markenanmeldung beim DPMA in Vorbereitung) und von der Lizenz ausgenommen. Weiterverbreitungen unter anderem Namen sind nach der Lizenz frei, dürfen aber nicht den Eindruck erwecken, vom Kurszettel zu stammen. Schriften unter der SIL Open Font License (`assets/fonts`).

Verantwortlich: Steffen Reukauf, podcast@kurszettel.com.
