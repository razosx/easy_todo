#!/usr/bin/env dart
// Verifies that every key in app_en.arb also exists in app_es.arb.
// Exits with code 1 and prints missing keys if any are found.

import 'dart:convert';
import 'dart:io';

void main() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final projectDir = scriptDir.parent;

  final enFile = File('${projectDir.path}/lib/l10n/app_en.arb');
  final esFile = File('${projectDir.path}/lib/l10n/app_es.arb');

  if (!enFile.existsSync()) {
    stderr.writeln('❌  Not found: ${enFile.path}');
    exit(1);
  }
  if (!esFile.existsSync()) {
    stderr.writeln('❌  Not found: ${esFile.path}');
    exit(1);
  }

  final enMap = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final esMap = jsonDecode(esFile.readAsStringSync()) as Map<String, dynamic>;

  // Ignore metadata keys (start with @)
  final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();
  final esKeys = esMap.keys.where((k) => !k.startsWith('@')).toSet();

  final missing = enKeys.difference(esKeys);
  final extra = esKeys.difference(enKeys);

  var hasErrors = false;

  if (missing.isNotEmpty) {
    hasErrors = true;
    stderr.writeln('❌  Keys in app_en.arb missing from app_es.arb:');
    final sortedMissing = missing.toList()..sort();
    for (final key in sortedMissing) {
      stderr.writeln('    - $key');
    }
  }

  if (extra.isNotEmpty) {
    hasErrors = true;
    stderr.writeln('❌  Keys in app_es.arb missing from app_en.arb:');
    final sortedExtra = extra.toList()..sort();
    for (final key in sortedExtra) {
      stderr.writeln('    - $key');
    }
  }

  if (hasErrors) {
    stderr.writeln('');
    stderr.writeln('Fix the .arb files and run: make l10n');
    exit(1);
  }

  stdout.writeln(
    '✅  app_en.arb and app_es.arb are in sync (${enKeys.length} keys).',
  );
}
