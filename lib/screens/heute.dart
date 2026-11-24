import 'package:flutter/material.dart';

import '../api.dart';
import '../format.dart';
import '../logo.dart';
import '../player.dart';
import '../theme.dart';
import 'folgen.dart';
import 'news.dart';

/// Startseite: Nachrichten, die nächsten wichtigen Termine und die neueste Folge – wie die Website.
class HeuteSeite extends StatefulWidget {
  const HeuteSeite({super.key, required this.zeigeBereich});

  /// Wechselt zu einem Reiter (1 = News, 2 = Termine, 3 = Folgen).
  final void Function(int) zeigeBereich;

  @override
  State<HeuteSeite> createState() => _HeuteSeiteState();
}

class _HeuteDaten {
  _HeuteDaten(this.news, this.termine, this.folgen);
  final MeldungsListe? news;
  final TerminListe? termine;
  final List<Folge>? folgen;
}

class _HeuteSeiteState extends State<HeuteSeite> {
  late Future<_HeuteDaten> _daten;

  @override
  void initState() {
    super.initState();
    _daten = _laden();
  }

  Future<T?> _sicher<T>(Future<T> f) async {
    try {
      return await f;
    } catch (_) {
      return null;
    }
  }

  Future<_HeuteDaten> _laden() async {
    final r = await Future.wait([
      _sicher(ladeNews()),
      _sicher(ladeTermine(nurWichtige: true)),
      _sicher(ladeFolgen()),
    ]);
    return _HeuteDaten(r[0] as MeldungsListe?, r[1] as TerminListe?, r[2] as List<Folge>?);
  }

  Future<void> _neu() async {
    final f = _laden();
    setState(() => _daten = f);
    await f;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HeuteDaten>(
      future: _daten,
      builder: (context, snap) {
        final d = snap.data;
        return RefreshIndicator(
          onRefresh: _neu,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(16, 20, 16, 18), child: Center(child: LogoBlock(groesse: 40))),
              if (d == null) const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator())),
              if (d != null && d.news == null && d.termine == null && d.folgen == null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    const Text('Keine Verbindung zu kurszettel.com.', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _neu, child: const Text('Erneut versuchen')),
                  ]),
                ),
              if (d?.news != null) ..._nachrichten(context, d!.news!),
              if (d?.termine != null) ..._termine(context, d!.termine!),
              if (d?.folgen != null && d!.folgen!.isNotEmpty) ..._folge(context, d.folgen!.first),
            ],
          ),
        );
      },
    );
  }

  Widget _kopf(String titel, String mehr, int reiter) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 8, 8),
        child: Row(children: [
          Expanded(child: Text(titel.toUpperCase(), style: KZ.rubrik)),
          TextButton(onPressed: () => widget.zeigeBereich(reiter), child: Text('$mehr →', style: const TextStyle(fontFamily: KZ.mono, fontSize: 12))),
        ]),
      );

  List<Widget> _nachrichten(BuildContext context, MeldungsListe n) {
    final liste = n.meldungen.where((m) => !m.entfernt).take(5).toList();
    if (liste.isEmpty) return [];
    return [
      _kopf('Kurzmeldungen', 'Alle', 1),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: KZ.panel, borderRadius: BorderRadius.circular(8), border: Border.all(color: KZ.linie)),
        child: Column(children: [
          for (var i = 0; i < liste.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _MeldungKurz(meldung: liste[i]),
          ],
        ]),
      ),
      const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 0), child: HinweisZeile()),
    ];
  }

  List<Widget> _termine(BuildContext context, TerminListe t) {
    final jetzt = DateTime.now().subtract(const Duration(hours: 1));
    final liste = t.termine.where((e) => e.zeitpunkt == null || e.zeitpunkt!.isAfter(jetzt)).take(6).toList();
    if (liste.isEmpty) return [];
    return [
      _kopf('Die nächsten Termine', 'Kalender', 2),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: KZ.panel, borderRadius: BorderRadius.circular(8), border: Border.all(color: KZ.linie)),
        child: Column(children: [
          for (var i = 0; i < liste.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _TerminKurz(termin: liste[i]),
          ],
        ]),
      ),
    ];
  }

  List<Widget> _folge(BuildContext context, Folge f) {
    final sp = Spieler.instanz;
    return [
      _kopf('Neueste Folge', 'Alle Folgen', 3),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Material(
          color: KZ.panel,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FolgeDetail(folge: f))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (f.bild.isNotEmpty)
                AspectRatio(aspectRatio: 16 / 9, child: Image.network(f.bild, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.titel, style: KZ.titel(17)),
                      const SizedBox(height: 4),
                      Text([if (f.datum != null) tagKurz(f.datum!), if (f.dauer > 0) dauer(f.dauer)].join(' · '), style: KZ.meta),
                    ]),
                  ),
                  ListenableBuilder(
                    listenable: sp,
                    builder: (context, _) {
                      final laeuft = sp.url == f.audio && sp.spielt;
                      return IconButton(
                        iconSize: 44,
                        color: KZ.gold,
                        tooltip: laeuft ? 'Pause' : 'Anhören',
                        icon: Icon(laeuft ? Icons.pause_circle_filled : Icons.play_circle_filled),
                        onPressed: f.audio.isEmpty ? null : () => sp.spiele(f.audio, f.titel, bild: f.bild, art: 'Podcast'),
                      );
                    },
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    ];
  }
}

class _MeldungKurz extends StatelessWidget {
  const _MeldungKurz({required this.meldung});
  final Meldung meldung;

  @override
  Widget build(BuildContext context) {
    final m = meldung;
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MeldungDetail(meldung: m))),
      child: Container(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: m.wichtig ? KZ.gold : Colors.transparent, width: 3))),
        padding: const EdgeInsets.fromLTRB(13, 12, 14, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text([if (m.datum != null) tagUndZeit(m.datum!), if (m.kategorie.isNotEmpty) m.kategorie.toUpperCase()].join(' · '), style: KZ.meta),
          const SizedBox(height: 4),
          Text(m.titel, style: KZ.titel(16)),
        ]),
      ),
    );
  }
}

class _TerminKurz extends StatelessWidget {
  const _TerminKurz({required this.termin});
  final Termin termin;

  @override
  Widget build(BuildContext context) {
    final t = termin;
    final d = t.zeitpunkt ?? DateTime.tryParse(t.datum);
    final wann = d == null ? t.datum : (t.ohneZeit ? '${tagKurz(d)}\nganzer Tag' : '${tagKurz(d)}\n${zwei(d.hour)}:${zwei(d.minute)} Uhr');
    return Container(
      decoration: BoxDecoration(border: Border(left: BorderSide(color: t.wichtig ? KZ.gold : Colors.transparent, width: 3))),
      padding: const EdgeInsets.fromLTRB(13, 10, 14, 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 112, child: Text(wann, style: KZ.meta.copyWith(color: KZ.creme))),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.titel, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (t.erklaerung.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Text(t.erklaerung, style: KZ.meta)),
          ]),
        ),
      ]),
    );
  }
}
