import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Öffnet eine Adresse außerhalb der App (Browser, Kalender, YouTube).
Future<void> oeffne(BuildContext context, String adresse) async {
  if (adresse.isEmpty) return;
  bool ok;
  try {
    ok = await launchUrl(Uri.parse(adresse), mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konnte die Adresse nicht öffnen.')));
  }
}
