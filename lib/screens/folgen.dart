import 'package:flutter/material.dart';

import '../api.dart';
import '../format.dart';
import '../links.dart';
import '../player.dart';
import '../theme.dart';
import '../widgets.dart';

class FolgenSeite extends StatelessWidget {
  const FolgenSeite({super.key});

  @override
  Widget build(BuildContext context) {
    return Lader<List<Folge>>(
      laden: ladeFolgen,
      anzeige: (context, folgen, _) {
        if (folgen.isEmpty) return ListView(children: const [SizedBox(height: 80), Center(child: Text('Noch keine Folgen.'))]);
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: folgen.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) => _FolgeKachel(folge: folgen[i]),
        );
      },
    );
  }
}

class _FolgeKachel extends StatelessWidget {
  const _FolgeKachel({required this.folge});
  final Folge folge;

  @override
  Widget build(BuildContext context) {
    final sp = Spieler.instanz;
    final unterzeile = [
      if (folge.datum != null) tagKurz(folge.datum!),
      if (folge.dauer > 0) dauer(folge.dauer),
      if (folge.thema.isNotEmpty) folge.thema,
    ].join(' · ');
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FolgeDetail(folge: folge))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 112,
                height: 63,
                child: folge.bild.isEmpty
                    ? Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)
                    : Image.network(folge.bild, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(folge.titel, maxLines: 3, overflow: TextOverflow.ellipsis, style: KZ.titel(15)),
                  const SizedBox(height: 4),
                  Text(unterzeile, style: KZ.meta),
                ],
              ),
            ),
            ListenableBuilder(
              listenable: sp,
              builder: (context, _) {
                final laeuft = sp.url == folge.audio && sp.spielt;
                return IconButton(
                  color: KZ.gold,
                  tooltip: laeuft ? 'Pause' : 'Abspielen',
                  icon: Icon(laeuft ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 32),
                  onPressed: folge.audio.isEmpty ? null : () => sp.spiele(folge.audio, folge.titel, bild: folge.bild, art: 'Podcast'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FolgeDetail extends StatelessWidget {
  const FolgeDetail({super.key, required this.folge});
  final Folge folge;

  @override
  Widget build(BuildContext context) {
    final sp = Spieler.instanz;
    return Scaffold(
      appBar: AppBar(title: const Text('Folge')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (folge.bild.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(aspectRatio: 16 / 9, child: Image.network(folge.bild, fit: BoxFit.cover)),
            ),
          const SizedBox(height: 12),
          Text(folge.titel, style: KZ.titel(24)),
          const SizedBox(height: 4),
          Text([
            if (folge.datum != null) tagUndZeit(folge.datum!),
            if (folge.dauer > 0) dauer(folge.dauer),
          ].join(' · '), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(
              onPressed: folge.audio.isEmpty ? null : () => sp.spiele(folge.audio, folge.titel, bild: folge.bild, art: 'Podcast'),
              icon: const Icon(Icons.headphones),
              label: const Text('Anhören'),
            ),
            if (folge.youtube.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => oeffne(context, folge.youtube),
                icon: const Icon(Icons.ondemand_video),
                label: const Text('Auf YouTube ansehen'),
              ),
          ]),
          const SizedBox(height: 16),
          SelectableText(folge.text, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 16),
          if (folge.seite.isNotEmpty)
            TextButton(onPressed: () => oeffne(context, folge.seite), child: const Text('Folgenseite auf kurszettel.com')),
        ],
      ),
      bottomNavigationBar: const MiniSpieler(),
    );
  }
}
