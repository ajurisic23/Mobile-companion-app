import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tool/generate_can_modules.dart' as generator;

void main() {
  late Directory tempDirectory;
  late Directory originalDirectory;

  const basePubspec = '''
name: test_app

dependencies:
  flutter:
    sdk: flutter
  can_core:
    path: packages/can_core

  # BEGIN GENERATED CAN MODULES
  # END GENERATED CAN MODULES

dev_dependencies:
  flutter_test:
    sdk: flutter
''';

  Map<String, dynamic> moduleConfig(
      String package,
      String className,
      int order,
      ) {
    return {
      'package': package,
      'entrypoint': '$package.dart',
      'class': className,
      'order': order,
    };
  }

  Directory createModule(
      String package,
      String className,
      int order,
      ) {
    final directory = Directory(
      '${tempDirectory.path}/packages/$package',
    );

    directory.createSync(recursive: true);

    File('${directory.path}/pubspec.yaml')
        .writeAsStringSync('name: $package\n');

    final libDirectory = Directory('${directory.path}/lib');
    libDirectory.createSync();

    File('${libDirectory.path}/$package.dart')
        .writeAsStringSync('class $className {}');

    File('${directory.path}/can_module.json')
        .writeAsStringSync(
      jsonEncode(moduleConfig(package, className, order)),
    );

    return directory;
  }

  setUp(() {
    originalDirectory = Directory.current;

    tempDirectory = Directory.systemTemp.createTempSync(
      'can_module_generator_test_',
    );

    Directory('${tempDirectory.path}/packages')
        .createSync();

    Directory.current = tempDirectory;
  });

  tearDown(() {
    Directory.current = originalDirectory;

    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  group('Module discovery', () {
    test('discovers all configured CAN modules', () {
      createModule('can_cards', 'CanCardsView', 10);
      createModule('can_list', 'CanListView', 20);
      createModule('can_gauge', 'CanGaugeView', 30);

      final modules = generator.discoverModules();

      expect(modules.length, 3);
      expect(
        modules.map((module) => module['package']),
        ['can_cards', 'can_list', 'can_gauge'],
      );
    });

    test('ignores packages without a module configuration', () {
      Directory('packages/can_core').createSync();

      createModule('can_cards', 'CanCardsView', 10);

      final modules = generator.discoverModules();

      expect(modules.length, 1);
      expect(modules.first['package'], 'can_cards');
    });

    test('ignores files in the packages directory', () {
      File('packages/README.md').writeAsStringSync('Test');

      expect(generator.discoverModules(), isEmpty);
    });

    test('returns an empty list when no modules exist', () {
      expect(generator.discoverModules(), isEmpty);
    });

    test('sorts modules by configured order', () {
      createModule('can_gauge', 'CanGaugeView', 30);
      createModule('can_cards', 'CanCardsView', 10);
      createModule('can_list', 'CanListView', 20);

      final modules = generator.discoverModules();

      expect(
        modules.map((module) => module['package']),
        ['can_cards', 'can_list', 'can_gauge'],
      );
    });

    test('sorts equal orders alphabetically', () {
      createModule('can_list', 'CanListView', 10);
      createModule('can_cards', 'CanCardsView', 10);

      final modules = generator.discoverModules();

      expect(
        modules.map((module) => module['package']),
        ['can_cards', 'can_list'],
      );
    });

    test('rejects a missing packages directory', () {
      Directory('packages').deleteSync(recursive: true);

      expect(
        generator.discoverModules,
        throwsFormatException,
      );
    });

    test('rejects malformed JSON configuration', () {
      final directory = createModule(
        'can_cards',
        'CanCardsView',
        10,
      );

      File('${directory.path}/can_module.json')
          .writeAsStringSync('{invalid json');

      expect(
        generator.discoverModules,
        throwsFormatException,
      );
    });

    test('rejects JSON configuration that is not an object', () {
      final directory = createModule(
        'can_cards',
        'CanCardsView',
        10,
      );

      File('${directory.path}/can_module.json')
          .writeAsStringSync('[]');

      expect(
        generator.discoverModules,
        throwsFormatException,
      );
    });
  });

  group('Module validation', () {
    late Directory directory;
    late Map<String, dynamic> config;

    setUp(() {
      directory = createModule(
        'can_cards',
        'CanCardsView',
        10,
      );

      config = moduleConfig(
        'can_cards',
        'CanCardsView',
        10,
      );
    });

    test('accepts a valid module configuration', () {
      expect(
            () => generator.validateModule(config, directory),
        returnsNormally,
      );
    });

    test('rejects an invalid package name', () {
      config['package'] = 'Invalid-Package';

      expect(
            () => generator.validateModule(config, directory),
        throwsFormatException,
      );
    });

    test('rejects an invalid entrypoint', () {
      config['entrypoint'] = '../invalid.dart';

      expect(
            () => generator.validateModule(config, directory),
        throwsFormatException,
      );
    });

    test('rejects an invalid class name', () {
      config['class'] = 'invalidClass';

      expect(
            () => generator.validateModule(config, directory),
        throwsFormatException,
      );
    });

    test('rejects negative module order', () {
      config['order'] = -1;

      expect(
            () => generator.validateModule(config, directory),
        throwsFormatException,
      );
    });

    test('rejects non-integer module order', () {
      config['order'] = '10';

      expect(
            () => generator.validateModule(config, directory),
        throwsFormatException,
      );
    });

    test('rejects a missing required property', () {
      config.remove('class');

      expect(
            () => generator.validateModule(config, directory),
        throwsFormatException,
      );
    });

    test('rejects a package and directory name mismatch', () {
      config['package'] = 'can_other';

      expect(
            () => generator.validateModule(config, directory),
        throwsFormatException,
      );
    });

    test('rejects a missing pubspec.yaml', () {
      File('${directory.path}/pubspec.yaml').deleteSync();

      expect(
            () => generator.validateModule(config, directory),
        throwsFormatException,
      );
    });

    test('rejects a missing entrypoint file', () {
      File('${directory.path}/lib/can_cards.dart')
          .deleteSync();

      expect(
            () => generator.validateModule(config, directory),
        throwsFormatException,
      );
    });
  });

  group('Registry generation', () {
    test('generates the shared interface import', () {
      final registry = generator.generateRegistry([]);

      expect(
        registry,
        contains("import 'package:can_core/can_core.dart';"),
      );
    });

    test('generates module imports and instances', () {
      final modules = [
        moduleConfig('can_cards', 'CanCardsView', 10),
        moduleConfig('can_list', 'CanListView', 20),
      ];

      final registry = generator.generateRegistry(modules);

      expect(
        registry,
        contains(
          "import 'package:can_cards/can_cards.dart' as module0;",
        ),
      );

      expect(
        registry,
        contains(
          "import 'package:can_list/can_list.dart' as module1;",
        ),
      );

      expect(registry, contains('module0.CanCardsView(),'));
      expect(registry, contains('module1.CanListView(),'));
    });

    test('generates a registry using CanSignalView', () {
      final registry = generator.generateRegistry([]);

      expect(
        registry,
        contains(
          'const List<CanSignalView> registeredCanViews = [',
        ),
      );
    });

    test('generates an empty registry without modules', () {
      final registry = generator.generateRegistry([]);

      expect(registry, isNot(contains('as module0')));
      expect(registry, isNot(contains('module0.')));
      expect(registry.trim(), endsWith('];'));
    });

    test('generates identical output for identical input', () {
      final modules = [
        moduleConfig('can_cards', 'CanCardsView', 10),
      ];

      expect(
        generator.generateRegistry(modules),
        generator.generateRegistry(modules),
      );
    });
  });

  group('Pubspec generation', () {
    test('adds discovered module dependencies', () {
      final modules = [
        moduleConfig('can_cards', 'CanCardsView', 10),
        moduleConfig('can_list', 'CanListView', 20),
      ];

      final result = generator.generatePubspec(
        basePubspec,
        modules,
      );

      expect(result, contains('  can_cards:'));
      expect(result, contains('    path: packages/can_cards'));
      expect(result, contains('  can_list:'));
      expect(result, contains('    path: packages/can_list'));
    });

    test('preserves dependencies outside generated markers', () {
      final result = generator.generatePubspec(
        basePubspec,
        [moduleConfig('can_cards', 'CanCardsView', 10)],
      );

      expect(result, contains('name: test_app'));
      expect(result, contains('  can_core:'));
      expect(result, contains('    path: packages/can_core'));
      expect(result, contains('dev_dependencies:'));
      expect(result, contains('  flutter_test:'));
    });

    test('removes dependencies for removed modules', () {
      final initial = generator.generatePubspec(
        basePubspec,
        [
          moduleConfig('can_cards', 'CanCardsView', 10),
          moduleConfig('can_list', 'CanListView', 20),
        ],
      );

      final updated = generator.generatePubspec(
        initial,
        [moduleConfig('can_cards', 'CanCardsView', 10)],
      );

      expect(updated, contains('  can_cards:'));
      expect(updated, isNot(contains('  can_list:')));
    });

    test('removes all generated dependencies when empty', () {
      final initial = generator.generatePubspec(
        basePubspec,
        [moduleConfig('can_cards', 'CanCardsView', 10)],
      );

      final updated = generator.generatePubspec(initial, []);

      expect(updated, basePubspec);
    });

    test('rejects missing generated markers', () {
      expect(
            () => generator.generatePubspec(
          'name: test_app',
          [],
        ),
        throwsFormatException,
      );
    });

    test('rejects reversed generated markers', () {
      const invalid = '''
  # END GENERATED CAN MODULES
  # BEGIN GENERATED CAN MODULES
''';

      expect(
            () => generator.generatePubspec(invalid, []),
        throwsFormatException,
      );
    });

    test('rejects duplicate generated markers', () {
      final invalid = '$basePubspec\n'
          '  # BEGIN GENERATED CAN MODULES\n';

      expect(
            () => generator.generatePubspec(invalid, []),
        throwsFormatException,
      );
    });

    test('preserves Windows line endings', () {
      final windowsPubspec = basePubspec.replaceAll(
        '\n',
        '\r\n',
      );

      final result = generator.generatePubspec(
        windowsPubspec,
        [moduleConfig('can_cards', 'CanCardsView', 10)],
      );

      expect(
        result,
        contains(
          '  can_cards:\r\n'
              '    path: packages/can_cards\r\n',
        ),
      );
    });

    test('is idempotent for identical modules', () {
      final modules = [
        moduleConfig('can_cards', 'CanCardsView', 10),
      ];

      final first = generator.generatePubspec(
        basePubspec,
        modules,
      );

      final second = generator.generatePubspec(
        first,
        modules,
      );

      expect(second, first);
    });
  });

  group('File generation', () {
    test('creates missing parent directories and file', () {
      final file = File('generated/nested/registry.dart');

      generator.writeIfChanged(file, 'Generated content');

      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), 'Generated content');
    });

    test('updates a file when content changes', () {
      final file = File('registry.dart');

      generator.writeIfChanged(file, 'Original content');
      generator.writeIfChanged(file, 'Updated content');

      expect(file.readAsStringSync(), 'Updated content');
    });

    test('does not rewrite an unchanged file', () {
      final file = File('registry.dart');

      generator.writeIfChanged(file, 'Same content');

      file.setLastModifiedSync(DateTime(2020, 1, 1));

      final originalModified = file.lastModifiedSync();

      generator.writeIfChanged(file, 'Same content');

      expect(file.lastModifiedSync(), originalModified);
    });
  });

  group('Module lifecycle', () {
    test('automatically discovers a newly added module', () {
      createModule('can_cards', 'CanCardsView', 10);

      expect(generator.discoverModules().length, 1);

      createModule('can_gauge', 'CanGaugeView', 30);

      final modules = generator.discoverModules();

      expect(modules.length, 2);

      final registry = generator.generateRegistry(modules);
      final pubspec = generator.generatePubspec(
        basePubspec,
        modules,
      );

      expect(registry, contains('CanGaugeView()'));
      expect(pubspec, contains('  can_gauge:'));
    });

    test('automatically excludes a removed module', () {
      createModule('can_cards', 'CanCardsView', 10);

      final gaugeDirectory = createModule(
        'can_gauge',
        'CanGaugeView',
        30,
      );

      final initialModules = generator.discoverModules();

      final initialPubspec = generator.generatePubspec(
        basePubspec,
        initialModules,
      );

      gaugeDirectory.deleteSync(recursive: true);

      final remainingModules = generator.discoverModules();

      final registry = generator.generateRegistry(
        remainingModules,
      );

      final pubspec = generator.generatePubspec(
        initialPubspec,
        remainingModules,
      );

      expect(remainingModules.length, 1);
      expect(registry, isNot(contains('CanGaugeView')));
      expect(pubspec, isNot(contains('  can_gauge:')));
    });

    test('generates registry and pubspec through main', () {
      File('pubspec.yaml').writeAsStringSync(basePubspec);

      createModule('can_cards', 'CanCardsView', 10);
      createModule('can_list', 'CanListView', 20);
      createModule('can_gauge', 'CanGaugeView', 30);

      generator.main();

      final registryFile = File(
        'lib/features/dashboard/generated/'
            'can_module_registry.g.dart',
      );

      expect(registryFile.existsSync(), isTrue);

      final registry = registryFile.readAsStringSync();
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(registry, contains('CanCardsView()'));
      expect(registry, contains('CanListView()'));
      expect(registry, contains('CanGaugeView()'));

      expect(pubspec, contains('  can_cards:'));
      expect(pubspec, contains('  can_list:'));
      expect(pubspec, contains('  can_gauge:'));
    });
  });
}