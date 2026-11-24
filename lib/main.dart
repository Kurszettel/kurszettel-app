import 'package:flutter/foundation.dart' show LicenseRegistry, LicenseEntryWithLineBreaks;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'api.dart' show kUserAgent;
import 'logo.dart';
import 'player.dart';
import 'screens/folgen.dart';
import 'screens/heute.dart';
import 'screens/einstellungen.dart';
import 'screens/news.dart';
import 'screens/termine.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Wiedergabe läuft weiter, wenn der Bildschirm gesperrt oder die App gewechselt wird;
  // Steuerung in der Mitteilungsleiste und auf dem Sperrbildschirm.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.kurszettel.app.audio',
    androidNotificationChannelName: 'Wiedergabe',
    androidNotificationOngoing: true,
  );
  // Kennung „Kurszettel-App/x.y.z“ für Abrufe bei kurszettel.com.
  try {
    final info = await PackageInfo.fromPlatform();
    kUserAgent = 'Kurszettel-App/${info.version}';
  } catch (_) {}
  // Lizenzen der eingebetteten Schriften (SIL Open Font License 1.1) in die Lizenzseite aufnehmen.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['IBM Plex Sans', 'IBM Plex Mono'], await rootBundle.loadString('assets/fonts/OFL-IBMPlex.txt'));
    yield LicenseEntryWithLineBreaks(['Libre Caslon Text'], await rootBundle.loadString('assets/fonts/OFL-LibreCaslonText.txt'));
  });
  runApp(const KurszettelApp());
}

class KurszettelApp extends StatelessWidget {
  const KurszettelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kurszettel',
      debugShowCheckedModeBanner: false,
      theme: kurszettelThema(),
      themeMode: ThemeMode.dark,
      home: const Startgeruest(),
    );
  }
}

class Startgeruest extends StatefulWidget {
  const Startgeruest({super.key});
  @override
  State<Startgeruest> createState() => _StartgeruestState();
}

class _StartgeruestState extends State<Startgeruest> {
  // Startreiter über ?tab=N (nur für Bildschirmfotos im Bau; auf dem Handy ohne Wirkung).
  int _seite = (int.tryParse(Uri.base.queryParameters['tab'] ?? '') ?? 0).clamp(0, 4);

  static const _titel = ['', 'Kurzmeldungen', 'Termine', 'Folgen', 'Einstellungen'];

  void _zeige(int i) => setState(() => _seite = i);

  @override
  Widget build(BuildContext context) {
    final seiten = [
      HeuteSeite(zeigeBereich: _zeige),
      const NewsSeite(),
      const TermineSeite(),
      const FolgenSeite(),
      const EinstellungenSeite(),
    ];
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: _seite == 0
            ? null
            : Row(children: [
                const Ticks(em: 34),
                const SizedBox(width: 12),
                Text(_titel[_seite]),
              ]),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: IndexedStack(index: _seite, children: seiten),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniSpieler(),
          NavigationBar(
            selectedIndex: _seite,
            onDestinationSelected: _zeige,
            height: 64,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Heute'),
              NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: 'News'),
              NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Termine'),
              NavigationDestination(icon: Icon(Icons.headphones_outlined), selectedIcon: Icon(Icons.headphones), label: 'Folgen'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Einstellungen'),
            ],
          ),
        ],
      ),
    );
  }
}
