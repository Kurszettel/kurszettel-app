import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'format.dart';
import 'theme.dart';

/// Ein gemeinsamer Spieler für Folgen und vorgelesene Meldungen.
/// Version 1: Wiedergabe in der App. Sperrbildschirm-Steuerung folgt (just_audio_background).
class Spieler extends ChangeNotifier {
  Spieler._() {
    _player.playerStateStream.listen((_) => notifyListeners());
  }
  static final Spieler instanz = Spieler._();

  final AudioPlayer _player = AudioPlayer();
  String? titel;
  String? url;

  AudioPlayer get player => _player;
  bool get aktiv => url != null;
  bool get spielt => _player.playing;

  Future<void> spiele(String neueUrl, String neuerTitel) async {
    if (neueUrl.isEmpty) return;
    if (url == neueUrl) {
      _player.playing ? await _player.pause() : await _player.play();
      return;
    }
    url = neueUrl;
    titel = neuerTitel;
    notifyListeners();
    try {
      await _player.setUrl(neueUrl);
      await _player.play();
    } catch (_) {
      url = null;
      titel = null;
      notifyListeners();
    }
  }

  Future<void> umschalten() async => _player.playing ? _player.pause() : _player.play();

  Future<void> stopp() async {
    await _player.stop();
    url = null;
    titel = null;
    notifyListeners();
  }

  Future<void> springe(int sekunden) async {
    final pos = _player.position + Duration(seconds: sekunden);
    await _player.seek(pos < Duration.zero ? Duration.zero : pos);
  }
}

/// Leiste über der Navigation, solange etwas läuft.
class MiniSpieler extends StatelessWidget {
  const MiniSpieler({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = Spieler.instanz;
    return ListenableBuilder(
      listenable: sp,
      builder: (context, _) {
        if (!sp.aktiv) return const SizedBox.shrink();
        return Material(
          color: KZ.panel,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(sp.titel ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: KZ.titel(14)),
                      ),
                      IconButton(tooltip: '15 Sekunden zurück', icon: const Icon(Icons.replay_10), onPressed: () => sp.springe(-15)),
                      IconButton(
                        tooltip: sp.spielt ? 'Pause' : 'Abspielen',
                        color: KZ.gold,
                        icon: Icon(sp.spielt ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 38),
                        onPressed: sp.umschalten,
                      ),
                      IconButton(tooltip: '30 Sekunden vor', icon: const Icon(Icons.forward_30), onPressed: () => sp.springe(30)),
                      IconButton(tooltip: 'Beenden', icon: const Icon(Icons.close), onPressed: sp.stopp),
                    ],
                  ),
                  StreamBuilder<Duration>(
                    stream: sp.player.positionStream,
                    builder: (context, snap) {
                      final pos = snap.data ?? Duration.zero;
                      final gesamt = sp.player.duration ?? Duration.zero;
                      final wert = gesamt.inMilliseconds > 0 ? pos.inMilliseconds / gesamt.inMilliseconds : 0.0;
                      return Row(
                        children: [
                          Text(laufzeit(pos), style: const TextStyle(fontSize: 12)),
                          Expanded(
                            child: Slider(
                              value: wert.clamp(0.0, 1.0),
                              onChanged: gesamt == Duration.zero
                                  ? null
                                  : (v) => sp.player.seek(Duration(milliseconds: (v * gesamt.inMilliseconds).round())),
                            ),
                          ),
                          Text(laufzeit(gesamt), style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
