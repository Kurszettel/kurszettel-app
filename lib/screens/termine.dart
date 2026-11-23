import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';
import '../format.dart';
import '../links.dart';
import '../theme.dart';
import '../widgets.dart';

const _regionen = {'de': 'Deutschland', 'ez': 'Eurozone', 'us': 'USA', 'co': 'Unternehmen'};

class TermineSeite extends StatefulWidget {
  const TermineSeite({super.key});
  @override
  State<TermineSeite> createState() => _TermineSeiteState();
}

class _TermineSeiteState extends State<TermineSeite> {
  Set<String> _auswahl = {};
  bool _nurWichtige = false;
  int _stand = 0; // erzwingt neues Laden bei geänderter Auswahl

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() {
        _auswahl = (p.getStringList('termine_regionen') ?? []).toSet();
        _nurWichtige = p.getBool('termine_wichtig') ?? false;
        _stand++;
      });
    });
  }

  Future<void> _merken() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('termine_regionen', _auswahl.toList());
    await p.setBool('termine_wichtig', _nurWichtige);
  }

  void _region(String r) {
    setState(() {
      _auswahl.contains(r) ? _auswahl.remove(r) : _auswahl.add(r);
      _stand++;
    });
    _merken();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(children: [
            FilterChip(
              label: const Text('Alle'),
              selected: _auswahl.isEmpty,
              onSelected: (_) {
                setState(() {
                  _auswahl = {};
                  _stand++;
                });
                _merken();
              },
            ),
            for (final e in _regionen.entries) ...[
              const SizedBox(width: 6),
              FilterChip(label: Text(e.value), selected: _auswahl.contains(e.key), onSelected: (_) => _region(e.key)),
            ],
          ]),
        ),
        SwitchListTile(
          dense: true,
          title: const Text('Nur die wichtigen'),
          value: _nurWichtige,
          onChanged: (v) {
            setState(() {
              _nurWichtige = v;
              _stand++;
            });
            _merken();
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: Lader<TerminListe>(
            key: ValueKey('termine-$_stand'),
            laden: () => ladeTermine(regionen: _auswahl, nurWichtige: _nurWichtige),
            anzeige: (context, daten, _) => _Liste(daten: daten),
          ),
        ),
      ],
    );
  }
}

class _Liste extends StatelessWidget {
  const _Liste({required this.daten});
  final TerminListe daten;

  @override
  Widget build(BuildContext context) {
    final kinder = <Widget>[];
    String? tag;
    for (final t in daten.termine) {
      if (t.datum != tag) {
        tag = t.datum;
        final d = DateTime.tryParse(t.datum);
        kinder.add(Abschnitt(d != null ? tagKurz(d) : t.datum));
      }
      kinder.add(_TerminZeile(termin: t));
    }
    if (daten.termine.isEmpty) {
      kinder.add(const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Keine Termine für diese Auswahl.'))));
    }
    if (daten.aboWebcal.isNotEmpty) {
      kinder.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: OutlinedButton.icon(
          onPressed: () => oeffne(context, daten.aboWebcal),
          icon: const Icon(Icons.event_repeat),
          label: const Text('Diese Auswahl als Kalender abonnieren'),
        ),
      ));
    }
    return ListView(children: kinder);
  }
}

class _TerminZeile extends StatelessWidget {
  const _TerminZeile({required this.termin});
  final Termin termin;

  @override
  Widget build(BuildContext context) {
    final t = termin;
        final zeit = t.ohneZeit ? 'ganztägig' : (t.zeitpunkt != null ? '${zwei(t.zeitpunkt!.hour)}:${zwei(t.zeitpunkt!.minute)}' : t.zeit);
    final zusatz = [
      _regionen[t.region] ?? t.region.toUpperCase(),
      if (t.zeitraum.isNotEmpty) t.zeitraum,
      if (t.vorlaeufig) 'Zeit vorläufig',
      if (t.eigenePosition) 'eigene Position',
    ].join(' · ');
    return Container(
      decoration: BoxDecoration(border: Border(left: BorderSide(color: t.wichtig ? KZ.gold : Colors.transparent, width: 3))),
      child: ListTile(
        leading: SizedBox(width: 64, child: Text(zeit, style: KZ.meta.copyWith(color: KZ.creme, fontSize: 13))),
        title: Text(t.titel, style: TextStyle(fontWeight: t.wichtig ? FontWeight.w600 : FontWeight.normal)),
        subtitle: Text([zusatz.toUpperCase(), if (t.erklaerung.isNotEmpty) t.erklaerung].join('\n'), style: KZ.meta),
        isThreeLine: t.erklaerung.isNotEmpty,
        trailing: IconButton(
          tooltip: 'In den Kalender',
          color: KZ.gold,
          icon: const Icon(Icons.event_available),
          onPressed: t.ics.isEmpty ? null : () => oeffne(context, t.ics),
        ),
      ),
    );
  }
}
