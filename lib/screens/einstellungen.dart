import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../api.dart';
import '../links.dart';
import '../logo.dart';
import '../theme.dart';
import '../widgets.dart';

/// Einstellungen im Stil der Android-Einstellungen: Abschnitte mit Zeilen.
/// Alles, was die App künftig an Einstellungen bekommt, kommt hier hinein.
class EinstellungenSeite extends StatefulWidget {
  const EinstellungenSeite({super.key});
  @override
  State<EinstellungenSeite> createState() => _EinstellungenSeiteState();
}

class _EinstellungenSeiteState extends State<EinstellungenSeite> {
  PackageInfo? _info;
  bool _sucht = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((i) {
      if (mounted) setState(() => _info = i);
    }).catchError((_) {});
  }

  String get _version => _info == null ? '…' : '${_info!.version} (${_info!.buildNumber})';

  Future<void> _updateSuchen() async {
    setState(() => _sucht = true);
    AppStand? stand;
    String? fehler;
    try {
      stand = await ladeAppStand();
    } catch (e) {
      fehler = e.toString();
    }
    if (!mounted) return;
    setState(() => _sucht = false);
    final eigene = int.tryParse(_info?.buildNumber ?? '') ?? 0;
    final String text;
    String? adresse;
    if (fehler != null) {
      text = fehler;
    } else if (stand == null) {
      text = 'Die Update-Prüfung über kurszettel.com ist noch nicht eingerichtet. Du nutzt Version $_version.';
    } else if (stand.build > eigene) {
      text = 'Version ${stand.version} ist verfügbar. Du nutzt $_version.';
      adresse = stand.url;
    } else {
      text = 'Du nutzt die aktuelle Version ($_version).';
    }
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: KZ.panel,
        title: Text('Update', style: KZ.titel(20)),
        content: Text(text),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Schließen')),
          if (adresse != null && adresse.isNotEmpty)
            FilledButton(
              onPressed: () {
                Navigator.pop(c);
                oeffne(context, adresse!);
              },
              child: const Text('Zur Download-Seite'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget zeile(IconData icon, String titel, {String? unter, VoidCallback? tippen, Widget? rechts}) => ListTile(
          leading: Icon(icon),
          title: Text(titel),
          subtitle: unter == null ? null : Text(unter, style: KZ.meta),
          trailing: rechts ?? (tippen == null ? null : const Icon(Icons.chevron_right, color: KZ.grau)),
          onTap: tippen,
        );
    Widget link(IconData icon, String titel, String adresse) => ListTile(
          leading: Icon(icon),
          title: Text(titel),
          trailing: const Icon(Icons.open_in_new, size: 18, color: KZ.grau),
          onTap: () => oeffne(context, adresse),
        );

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const Abschnitt('App'),
        zeile(Icons.system_update_alt, 'Nach Update suchen',
            unter: 'Installierte Version $_version',
            tippen: _sucht ? null : _updateSuchen,
            rechts: _sucht ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null),
        const Divider(),
        const Abschnitt('Über'),
        zeile(Icons.info_outline, 'Über Kurszettel',
            unter: 'Was die App ist und wer sie macht',
            tippen: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => UeberSeite(version: _version)))),
        zeile(Icons.balance, 'Lizenz', unter: 'Freie Software, GNU GPL Version 3 oder später'),
        zeile(Icons.description_outlined, 'Lizenzen der verwendeten Bausteine',
            tippen: () => showLicensePage(context: context, applicationName: 'Kurszettel', applicationVersion: _version)),
        const Divider(),
        const Abschnitt('Kanäle'),
        link(Icons.public, 'kurszettel.com', 'https://kurszettel.com'),
        link(Icons.ondemand_video, 'YouTube', 'https://www.youtube.com/@kurszettel'),
        link(Icons.podcasts, 'Spotify', 'https://open.spotify.com/show/1AjPTRZg4HPLlbWgRgS99F'),
        link(Icons.music_note, 'Amazon Music', 'https://music.amazon.de/podcasts/1e371c25-6c51-4ecc-9cb5-9695463f618d'),
        link(Icons.send, 'Telegram', 'https://t.me/kurszettel'),
        link(Icons.alternate_email, 'X', 'https://x.com/kurszettel'),
        const Divider(),
        const Abschnitt('Rechtliches'),
        link(Icons.list_alt, 'Positionen (Offenlegung)', 'https://kurszettel.com/positionen'),
        link(Icons.gavel, 'Hinweise', 'https://kurszettel.com/hinweise'),
        link(Icons.business, 'Impressum', 'https://kurszettel.com/impressum'),
        link(Icons.privacy_tip_outlined, 'Datenschutz', 'https://kurszettel.com/datenschutz'),
      ],
    );
  }
}

class UeberSeite extends StatelessWidget {
  const UeberSeite({super.key, required this.version});
  final String version;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Über Kurszettel')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        children: [
          const Center(child: LogoBlock(groesse: 40)),
          const SizedBox(height: 28),
          const Text(
            'Kurszettel berichtet an jedem Handelstag über das Geschehen an den Märkten: als Podcast, '
            'mit Kurzmeldungen aus Primärquellen und einem Kalender der wichtigen Termine.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 14),
          const Text(
            'Berichterstattung, keine Anlageberatung und keine Kauf- oder Verkaufsempfehlung. '
            'Eigene Wertpapierpositionen werden offengelegt.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 24),
          Text('HERAUSGEBER', style: KZ.rubrik),
          const SizedBox(height: 6),
          const Text('Steffen Reukauf\npodcast@kurszettel.com', style: TextStyle(height: 1.5)),
          const SizedBox(height: 20),
          Text('APP', style: KZ.rubrik),
          const SizedBox(height: 6),
          Text('Version $version\nFreie Software unter der GNU GPL, Version 3 oder später.\n'
              'Die App speichert keine persönlichen Daten; nur deine Terminauswahl bleibt auf dem Gerät.',
              style: const TextStyle(height: 1.5)),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(onPressed: () => oeffne(context, 'https://kurszettel.com/impressum'), child: const Text('Impressum')),
          ),
        ],
      ),
    );
  }
}
