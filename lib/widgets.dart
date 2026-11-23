import 'package:flutter/material.dart';

import 'theme.dart';

/// Lädt Daten, zeigt Ladeanzeige oder Fehler mit „Erneut versuchen“, erlaubt Herunterziehen zum Aktualisieren.
class Lader<T> extends StatefulWidget {
  const Lader({super.key, required this.laden, required this.anzeige});
  final Future<T> Function() laden;
  final Widget Function(BuildContext context, T daten, Future<void> Function() neu) anzeige;

  @override
  State<Lader<T>> createState() => LaderState<T>();
}

class LaderState<T> extends State<Lader<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.laden();
  }

  Future<void> neu() async {
    final f = widget.laden();
    setState(() => _future = f);
    try {
      await f;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(snap.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: neu, child: const Text('Erneut versuchen')),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(onRefresh: neu, child: widget.anzeige(context, snap.data as T, neu));
      },
    );
  }
}

class Abschnitt extends StatelessWidget {
  const Abschnitt(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
        child: Text(text.toUpperCase(), style: KZ.rubrik),
      );
}
