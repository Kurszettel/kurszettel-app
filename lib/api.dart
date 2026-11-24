import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Kennung der App bei Abrufen (wird beim Start um die Versionsnummer ergänzt).
String kUserAgent = 'Kurszettel-App';

/// Basisadresse der Schnittstelle (siehe Projektnotiz app-schnittstelle.md).
const String kApiBase = 'https://kurszettel.com/api';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

Future<Map<String, dynamic>> _getJson(String path, [Map<String, String>? query]) async {
  final uri = Uri.parse('$kApiBase/$path').replace(queryParameters: query);
  final http.Response res;
  try {
    res = await http.get(uri, headers: {'Accept': 'application/json', if (!kIsWeb) 'User-Agent': kUserAgent}).timeout(const Duration(seconds: 15));
  } catch (_) {
    throw ApiException('Keine Verbindung zu kurszettel.com.');
  }
  if (res.statusCode != 200) {
    throw ApiException('Server antwortet mit Fehler ${res.statusCode}.');
  }
  final data = jsonDecode(utf8.decode(res.bodyBytes));
  if (data is! Map<String, dynamic>) throw ApiException('Unerwartete Antwort.');
  return data;
}

DateTime? _date(dynamic v) => v is String && v.isNotEmpty ? DateTime.tryParse(v)?.toLocal() : null;
String _s(dynamic v) => v is String ? v : (v == null ? '' : v.toString());
bool _b(dynamic v) => v == true;

// ---------------- Folgen ----------------

class Folge {
  Folge.fromJson(Map<String, dynamic> j)
      : id = _s(j['id']),
        titel = _s(j['titel']),
        datum = _date(j['datum']),
        dauer = (j['dauer'] is int) ? j['dauer'] as int : 0,
        audio = _s(j['audio']),
        text = _s(j['text']),
        rubrik = _s(j['rubrik']),
        thema = _s(j['thema']),
        youtube = _s(j['youtube']),
        bild = _s(j['bild']),
        seite = _s(j['seite']);

  final String id, titel, audio, text, rubrik, thema, youtube, bild, seite;
  final DateTime? datum;
  final int dauer;
}

Future<List<Folge>> ladeFolgen() async {
  final d = await _getJson('folgen', {'limit': '100'});
  return ((d['folgen'] as List?) ?? []).whereType<Map<String, dynamic>>().map(Folge.fromJson).toList();
}

// ---------------- Termine ----------------

class Termin {
  Termin.fromJson(Map<String, dynamic> j)
      : id = _s(j['id']),
        datum = _s(j['datum']),
        zeit = _s(j['zeit']),
        zeitpunkt = _date(j['zeitpunkt']),
        ohneZeit = _b(j['ohne_zeit']),
        region = _s(j['region']),
        titel = _s(j['titel']),
        zeitraum = _s(j['zeitraum']),
        quelle = _s(j['quelle']),
        wichtig = _b(j['wichtig']),
        erklaerung = _s(j['erklaerung']),
        vorlaeufig = _b(j['vorlaeufig']),
        eigenePosition = _b(j['eigene_position']),
        ics = _s(j['ics']);

  final String id, datum, zeit, region, titel, zeitraum, quelle, erklaerung, ics;
  final DateTime? zeitpunkt;
  final bool ohneZeit, wichtig, vorlaeufig, eigenePosition;
}

class TerminListe {
  TerminListe(this.termine, this.aboWebcal);
  final List<Termin> termine;
  final String aboWebcal;
}

/// [regionen] leer = alle; Werte: de, ez, us, co.
Future<TerminListe> ladeTermine({Set<String> regionen = const {}, bool nurWichtige = false}) async {
  final q = <String, String>{'days': '42'};
  if (regionen.isNotEmpty) q['reg'] = regionen.join(',');
  if (nurWichtige) q['imp'] = '1';
  final d = await _getJson('termine', q);
  final liste = ((d['termine'] as List?) ?? []).whereType<Map<String, dynamic>>().map(Termin.fromJson).toList();
  final abo = (d['abo'] is Map) ? _s((d['abo'] as Map)['webcal']) : '';
  return TerminListe(liste, abo);
}

// ---------------- Nachrichten ----------------

class Meldung {
  Meldung.fromJson(Map<String, dynamic> j)
      : id = _s(j['id']),
        datum = _date(j['datum']),
        kategorie = _s(j['kategorie_name']),
        seite = _s(j['seite']),
        entfernt = _b(j['entfernt']),
        titel = _s(j['titel']),
        text = _s(j['text']),
        hinweis = _s(j['hinweis']),
        wichtig = _b(j['wichtig']),
        quelleName = (j['quelle'] is Map) ? _s((j['quelle'] as Map)['name']) : '',
        quelleUrl = (j['quelle'] is Map) ? _s((j['quelle'] as Map)['url']) : '',
        offenlegung = ((j['offenlegung'] as List?) ?? []).map(_s).where((s) => s.isNotEmpty).toList(),
        kennzeichnung = _s(j['kennzeichnung']),
        fusszeile = _s(j['fusszeile']),
        audio = _s(j['audio']),
        stimmeHinweis = _s(j['stimme_hinweis']),
        vermerke = ((j['vermerke'] as List?) ?? [])
            .whereType<Map>()
            .map((v) => '${_s(v['art'])}: ${_s(v['text'])}'.trim())
            .toList();

  final String id, kategorie, seite, titel, text, hinweis, quelleName, quelleUrl, kennzeichnung, fusszeile, audio, stimmeHinweis;
  final DateTime? datum;
  final bool entfernt, wichtig;
  final List<String> offenlegung, vermerke;
}

class MeldungsListe {
  MeldungsListe(this.meldungen, this.sprecherin);
  final List<Meldung> meldungen;
  final String sprecherin;
}

Future<MeldungsListe> ladeNews() async {
  final d = await _getJson('news', {'limit': '50'});
  final liste = ((d['news'] as List?) ?? []).whereType<Map<String, dynamic>>().map(Meldung.fromJson).toList();
  return MeldungsListe(liste, _s(d['sprecherin']));
}

// ---------------- App-Stand (Update über die Homepage) ----------------

class AppStand {
  AppStand(this.version, this.build, this.url);
  final String version;
  final int build;
  final String url;
}

/// Liest das Feld `app` der Schnittstellen-Übersicht ({version, build, url}); null, solange es fehlt.
Future<AppStand?> ladeAppStand() async {
  final d = await _getJson('');
  final a = d['app'];
  if (a is! Map) return null;
  final b = a['build'];
  return AppStand(_s(a['version']), b is int ? b : int.tryParse(_s(b)) ?? 0, _s(a['url']));
}
