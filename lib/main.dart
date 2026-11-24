import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'logo.dart';
import 'player.dart';
import 'screens/folgen.dart';
import 'screens/heute.dart';
import 'screens/info.dart';
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
  int _seite = (int.tryParse(Uri.base.queryParameters['tab'] ?? '') ?? 0).clamp(0, 3);

  static const _titel = ['', 'Kurzmeldungen', 'Termine', 'Folgen'];

  void _zeige(int i) => setState(() => _seite = i);

  @override
  Widget build(BuildContext context) {
    final seiten = [
      HeuteSeite(zeigeBereich: _zeige),
      const NewsSeite(),
      const TermineSeite(),
      const FolgenSeite(),
    ];
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: _seite == 0
            ? null
            : Row(children: [
                const Ticks(em: 18),
                const SizedBox(width: 10),
                Text(_titel[_seite]),
              ]),
        actions: [
          IconButton(
            tooltip: 'Über Kurszettel',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Scaffold(appBar: AppBar(title: const Text('Über Kurszettel')), body: const InfoSeite()),
            )),
          ),
        ],
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
            ],
          ),
        ],
      ),
    );
  }
}
