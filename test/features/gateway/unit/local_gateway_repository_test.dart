import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/models/gateway_info.dart';
import 'package:mobile_companion_app/features/gateway/services/gateway_repository.dart';
import 'package:mobile_companion_app/features/gateway/services/local_gateway_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = LocalGatewayRepository.storageKey;

const _first = GatewayInfo(
  name: 'Address 1',
  host: '192.168.0.100',
  port: 80,
);

const _second = GatewayInfo(
  name: 'Address 2',
  host: '192.168.0.101',
  port: 10000,
);

void _useStorage(Map<String, Object> values) {
  SharedPreferences.resetStatic();
  SharedPreferences.setMockInitialValues(values);
}

Future<String?> _storedText() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_key);
}

void main() {
  const repository = LocalGatewayRepository();

  setUp(() => _useStorage({}));

  group('saving and loading', () {
    test('returns an empty list when nothing is saved', () async {
      expect(await repository.getAll(), isEmpty);
    });

    test('saves a gateway and loads it back', () async {
      await repository.save(_first);

      expect(await repository.getAll(), [_first]);
    });

    test('keeps several gateways in the order they were saved', () async {
      await repository.save(_first);
      await repository.save(_second);

      expect(await repository.getAll(), [_first, _second]);
    });

    test('saved gateways are available after the app restarts', () async {
      await repository.save(_first);
      await repository.save(_second);
      final stored = await _storedText();

      _useStorage({_key: stored!});

      expect(await const LocalGatewayRepository().getAll(), [_first, _second]);
    });

    test('saving a gateway with the same address replaces it', () async {
      const renamed = GatewayInfo(
        name: 'Renamed',
        host: '192.168.0.100',
        port: 80,
      );

      await repository.save(_first);
      await repository.save(renamed);

      expect(await repository.getAll(), [renamed]);
    });
  });

  group('updating', () {
    test('replaces the original gateway with the updated one', () async {
      const edited = GatewayInfo(
        name: 'Edited',
        host: '192.168.0.100',
        port: 8080,
      );

      await repository.save(_first);
      await repository.save(_second);
      await repository.update(_first, edited);

      expect(await repository.getAll(), [edited, _second]);
    });

    test('throws when the new address belongs to another gateway', () async {
      const clashing = GatewayInfo(
        name: 'Clashing',
        host: '192.168.0.101',
        port: 10000,
      );

      await repository.save(_first);
      await repository.save(_second);

      await expectLater(
        repository.update(_first, clashing),
        throwsA(isA<DuplicateGatewayException>()),
      );
      expect(await repository.getAll(), [_first, _second]);
    });

    test('adds the gateway when the original is not found', () async {
      await repository.update(_first, _second);

      expect(await repository.getAll(), [_second]);
    });
  });

  group('deleting', () {
    test('removes the gateway', () async {
      await repository.save(_first);
      await repository.save(_second);
      await repository.delete(_first);

      expect(await repository.getAll(), [_second]);
    });

    test('does nothing when the gateway is not saved', () async {
      await repository.save(_first);
      await repository.delete(_second);

      expect(await repository.getAll(), [_first]);
    });
  });

  group('invalid stored data', () {
    test('returns an empty list when the text is not JSON', () async {
      _useStorage({_key: 'this is not json'});

      expect(await repository.getAll(), isEmpty);
    });

    test('returns an empty list when the JSON is not a list', () async {
      _useStorage({_key: jsonEncode({'host': '192.168.0.100', 'port': 80})});

      expect(await repository.getAll(), isEmpty);
    });

    test('returns an empty list when the stored value has the wrong type',
            () async {
          _useStorage({_key: 123});

          expect(await repository.getAll(), isEmpty);
        });

    test('skips invalid entries and keeps the valid ones', () async {
      _useStorage({
        _key: jsonEncode([
          _first.toJson(),
          'text',
          null,
          {'host': '', 'port': 80},
          {'host': '192.168.0.102'},
          {'host': '192.168.0.103', 'port': 0},
          _second.toJson(),
        ]),
      });

      expect(await repository.getAll(), [_first, _second]);
    });

    test('keeps only the first of two stored entries with the same address',
            () async {
          const duplicate = GatewayInfo(
            name: 'Duplicate',
            host: '192.168.0.100',
            port: 80,
          );

          _useStorage({
            _key: jsonEncode([_first.toJson(), duplicate.toJson()]),
          });

          expect(await repository.getAll(), [_first]);
        });

    test('can still save after the stored data was corrupted', () async {
      _useStorage({_key: 'this is not json'});

      await repository.save(_first);

      expect(await repository.getAll(), [_first]);
    });
  });
}