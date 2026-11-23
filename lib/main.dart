import 'package:flutter/material.dart';

import 'player.dart';
import 'screens/folgen.dart';
import 'screens/info.dart';
import 'screens/news.dart';
import 'screens/termine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KurszettelApp());
}

const kNavy = Color(0xFF0F1A2B);
const kGold = Color(0xFFB8962E);

class KurszettelApp extends StatelessWidget {
  const KurszettelApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData thema(Brightness b) {
      final schema = ColorScheme.fromSeed(seedColor: kNavy, brightness: b).copyWith(
        primary: b == Brightness.dark ? kGold : kNavy,
        secondary: kGold,
      );
      return ThemeData(colorScheme: schema, useMaterial3: true);
    }

    return MaterialApp(
      title: 'Kurszettel',
      debugShowCheckedModeBanner: false,
      theme: thema(Brightness.light),
      darkTheme: thema(Brightness.dark),
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
  int _seite = 0;

  static const _titel = ['Folgen', 'Termine', 'News', 'Info'];
  static const _seiten = [FolgenSeite(), TermineSeite(), NewsSeite(), InfoSeite()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kurszettel · ${_titel[_seite]}')),
      body: IndexedStack(index: _seite, children: _seiten),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniSpieler(),
          NavigationBar(
            selectedIndex: _seite,
            onDestinationSelected: (i) => setState(() => _seite = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.headphones_outlined), selectedIcon: Icon(Icons.headphones), label: 'Folgen'),
              NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Termine'),
              NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: 'News'),
              NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'Info'),
            ],
          ),
        ],
      ),
    );
  }
}
