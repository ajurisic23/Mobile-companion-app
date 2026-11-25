import 'dart:convert';
import 'dart:io';

void main() {
  try {
    final modules = discoverModules();

    final registryContent = generateRegistry(modules);

    final pubspecFile = File('pubspec.yaml');
    final pubspecContent = pubspecFile.readAsStringSync();

    final updatedPubspec = generatePubspec(
      pubspecContent,
      modules,
    );

    stdout.writeln('Discovered CAN modules:');

    for (final module in modules) {
      stdout.writeln(
        '- ${module['package']} -> ${module['class']}',
      );
    }

    stdout.writeln('Total modules: ${modules.length}');

    final registryFile = File(
      'lib/features/dashboard/generated/can_module_registry.g.dart',
    );

    writeIfChanged(registryFile, registryContent);
    writeIfChanged(pubspecFile, updatedPubspec);

    stdout.writeln('CAN module generation completed successfully.');
  } catch (error) {
    stderr.writeln('CAN module generation failed: $error');
    exitCode = 1;
  }
}

List<Map<String, dynamic>> discoverModules() {
  final packagesDirectory = Directory('packages');

  if (!packagesDirectory.existsSync()) {
    throw const FormatException('Packages directory not found.');
  }

  final modules = <Map<String, dynamic>>[];
  final packageNames = <String>{};

  for (final entity in packagesDirectory.listSync()) {
    if (entity is! Directory) {
      continue;
    }

    final configFile = File(
      '${entity.path}/can_module.json',
    );

    if (!configFile.existsSync()) {
      continue;
    }

    final decoded = jsonDecode(configFile.readAsStringSync());

    if (decoded is! Map<String, dynamic>) {
      throw FormatException(
        'Invalid JSON configuration: ${configFile.path}',
      );
    }

    validateModule(decoded, entity);

    final packageName = decoded['package'] as String;

    if (!packageNames.add(packageName)) {
      throw FormatException(
        'Duplicate CAN module package: $packageName',
      );
    }

    modules.add(decoded);
  }

  modules.sort((a, b) {
    final orderComparison =
    (a['order'] as int).compareTo(b['order'] as int);

    if (orderComparison != 0) {
      return orderComparison;
    }

    return (a['package'] as String)
        .compareTo(b['package'] as String);
  });

  return modules;
}

void validateModule(
    Map<String, dynamic> config,
    Directory directory,
    ) {
  final packageName = config['package'];
  final entrypoint = config['entrypoint'];
  final className = config['class'];
  final order = config['order'];

  if (packageName is! String ||
      !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(packageName)) {
    throw FormatException(
      'Invalid package name in ${directory.path}',
    );
  }

  if (entrypoint is! String ||
      !RegExp(r'^[a-zA-Z0-9_]+\.dart$').hasMatch(entrypoint)) {
    throw FormatException(
      'Invalid entrypoint in ${directory.path}',
    );
  }

  if (className is! String ||
      !RegExp(r'^[A-Z][a-zA-Z0-9_]*$').hasMatch(className)) {
    throw FormatException(
      'Invalid class name in ${directory.path}',
    );
  }

  if (order is! int || order < 0) {
    throw FormatException(
      'Invalid module order in ${directory.path}',
    );
  }

  final directoryName = directory.uri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .last;

  if (packageName != directoryName) {
    throw FormatException(
      'Package name $packageName does not match '
          'directory name $directoryName.',
    );
  }

  final pubspecFile = File('${directory.path}/pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    throw FormatException(
      'Missing pubspec.yaml in ${directory.path}',
    );
  }

  final entrypointFile = File(
    '${directory.path}/lib/$entrypoint',
  );

  if (!entrypointFile.existsSync()) {
    throw FormatException(
      'Module entrypoint not found: ${entrypointFile.path}',
    );
  }
}

String generateRegistry(
    List<Map<String, dynamic>> modules,
    ) {
  final buffer = StringBuffer();

  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.');
  buffer.writeln();
  buffer.writeln("import 'package:can_core/can_core.dart';");

  for (var i = 0; i < modules.length; i++) {
    final module = modules[i];

    buffer.writeln(
      "import 'package:${module['package']}/"
          "${module['entrypoint']}' as module$i;",
    );
  }

  buffer.writeln();
  buffer.writeln(
    'const List<CanSignalView> registeredCanViews = [',
  );

  for (var i = 0; i < modules.length; i++) {
    buffer.writeln(
      "  module$i.${modules[i]['class']}(),",
    );
  }

  buffer.writeln('];');

  return buffer.toString();
}

String generatePubspec(
    String content,
    List<Map<String, dynamic>> modules,
    ) {
  const startMarker = '  # BEGIN GENERATED CAN MODULES';
  const endMarker = '  # END GENERATED CAN MODULES';

  final startIndex = content.indexOf(startMarker);
  final endIndex = content.indexOf(endMarker);

  if (startIndex == -1 ||
      endIndex == -1 ||
      endIndex <= startIndex ||
      startIndex != content.lastIndexOf(startMarker) ||
      endIndex != content.lastIndexOf(endMarker)) {
    throw const FormatException(
      'Invalid CAN module markers in pubspec.yaml.',
    );
  }

  final lineEnding = content.contains('\r\n') ? '\r\n' : '\n';

  final lines = <String>[startMarker];

  for (final module in modules) {
    final packageName = module['package'] as String;

    lines.add('  $packageName:');
    lines.add('    path: packages/$packageName');
  }

  lines.add(endMarker);

  return content.replaceRange(
    startIndex,
    endIndex + endMarker.length,
    lines.join(lineEnding),
  );
}

void writeIfChanged(File file, String content) {
  if (file.existsSync() &&
      file.readAsStringSync() == content) {
    stdout.writeln('Up to date: ${file.path}');
    return;
  }

  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);

  stdout.writeln('Updated: ${file.path}');
}