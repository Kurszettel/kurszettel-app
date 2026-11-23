import 'package:flutter/material.dart';

import '../api.dart';
import '../format.dart';
import '../links.dart';
import '../player.dart';
import '../widgets.dart';

class NewsSeite extends StatelessWidget {
  const NewsSeite({super.key});

  @override
  Widget build(BuildContext context) {
    return Lader<MeldungsListe>(
      laden: ladeNews,
      anzeige: (context, daten, _) {
        final m = daten.meldungen;
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: m.length + 1,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            if (i == m.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gelesen von ${daten.sprecherin.isEmpty ? 'unserer digitalen Sprecherin' : daten.sprecherin}. '
                  'Berichterstattung, keine Anlageberatung, keine Kauf- oder Verkaufsempfehlung.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
            return _MeldungKachel(meldung: m[i]);
          },
        );
      },
    );
  }
}

class _MeldungKachel extends StatelessWidget {
  const _MeldungKachel({required this.meldung});
  final Meldung meldung;

  @override
  Widget build(BuildContext context) {
    final m = meldung;
    if (m.entfernt) {
      return ListTile(title: const Text('Meldung entfernt'), subtitle: m.hinweis.isEmpty ? null : Text(m.hinweis));
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      title: Text(m.titel, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text([
        if (m.datum != null) tagUndZeit(m.datum!),
        if (m.kategorie.isNotEmpty) m.kategorie,
      ].join(' · ')),
      trailing: m.audio.isEmpty ? null : _VorlesenKnopf(meldung: m),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MeldungDetail(meldung: m))),
    );
  }
}

class _VorlesenKnopf extends StatelessWidget {
  const _VorlesenKnopf({required this.meldung});
  final Meldung meldung;

  @override
  Widget build(BuildContext context) {
    final sp = Spieler.instanz;
    return ListenableBuilder(
      listenable: sp,
      builder: (context, _) {
        final laeuft = sp.url == meldung.audio && sp.spielt;
        return IconButton(
          tooltip: laeuft ? 'Pause' : 'Vorlesen',
          icon: Icon(laeuft ? Icons.pause_circle_outline : Icons.record_voice_over_outlined),
          onPressed: () => sp.spiele(meldung.audio, meldung.titel),
        );
      },
    );
  }
}

class MeldungDetail extends StatelessWidget {
  const MeldungDetail({super.key, required this.meldung});
  final Meldung meldung;

  @override
  Widget build(BuildContext context) {
    final m = meldung;
    final klein = Theme.of(context).textTheme.bodySmall;
    final absaetze = m.text.split(RegExp(r'\n\s*\n')).where((a) => a.trim().isNotEmpty);
    return Scaffold(
      appBar: AppBar(title: const Text('Meldung')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text([
            if (m.datum != null) tagUndZeit(m.datum!),
            if (m.kategorie.isNotEmpty) m.kategorie,
          ].join(' · '), style: klein),
          const SizedBox(height: 6),
          Text(m.titel, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (m.audio.isNotEmpty)
            Align(alignment: Alignment.centerLeft, child: _VorlesenKnopf(meldung: m)),
          for (final a in absaetze) Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableText(a.trim())),
          for (final v in m.vermerke) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(v, style: klein)),
          for (final o in m.offenlegung) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(o, style: klein)),
          const SizedBox(height: 8),
          if (m.kennzeichnung.isNotEmpty) Text(m.kennzeichnung, style: klein),
          if (m.stimmeHinweis.isNotEmpty) Text(m.stimmeHinweis, style: klein),
          if (m.quelleUrl.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => oeffne(context, m.quelleUrl),
                child: Text('Quelle öffnen${m.quelleName.isNotEmpty ? ': ${m.quelleName}' : ''}'),
              ),
            ),
          if (m.fusszeile.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(m.fusszeile, style: klein)),
        ],
      ),
      bottomNavigationBar: const MiniSpieler(),
    );
  }
}
