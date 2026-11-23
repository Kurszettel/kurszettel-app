import 'package:flutter/material.dart';

import '../links.dart';
import '../widgets.dart';

class InfoSeite extends StatelessWidget {
  const InfoSeite({super.key});

  @override
  Widget build(BuildContext context) {
    Widget link(String titel, String adresse, IconData icon) =>
        ListTile(leading: Icon(icon), title: Text(titel), onTap: () => oeffne(context, adresse), trailing: const Icon(Icons.open_in_new, size: 18));
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            'Kurszettel berichtet über das Geschehen an den Märkten. Berichterstattung, keine Anlageberatung und '
            'keine Kauf- oder Verkaufsempfehlung. Eigene Wertpapierpositionen werden offengelegt.',
          ),
        ),
        const Abschnitt('Hören und sehen'),
        link('YouTube', 'https://www.youtube.com/@kurszettel', Icons.ondemand_video),
        link('Spotify', 'https://open.spotify.com/show/1AjPTRZg4HPLlbWgRgS99F', Icons.podcasts),
        link('Telegram', 'https://t.me/kurszettel', Icons.send),
        link('Amazon Music', 'https://music.amazon.de/podcasts/1e371c25-6c51-4ecc-9cb5-9695463f618d', Icons.music_note),
        link('kurszettel.com', 'https://kurszettel.com', Icons.public),
        const Abschnitt('Rechtliches'),
        link('Positionen (Offenlegung)', 'https://kurszettel.com/positionen', Icons.list_alt),
        link('Hinweise', 'https://kurszettel.com/hinweise', Icons.info_outline),
        link('Impressum', 'https://kurszettel.com/impressum', Icons.business),
        link('Datenschutz', 'https://kurszettel.com/datenschutz', Icons.privacy_tip_outlined),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Testfassung – Rückmeldungen bitte an podcast@kurszettel.com.', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
