import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/gateway_info.dart';
import 'gateway_repository.dart';

class LocalGatewayRepository implements GatewayRepository {
  const LocalGatewayRepository();

  static const storageKey = 'saved_gateways';

  @override
  Future<List<GatewayInfo>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return _decode(_readRaw(prefs));
  }

  @override
  Future<void> save(GatewayInfo gateway) async {
    final prefs = await SharedPreferences.getInstance();
    final gateways = _decode(_readRaw(prefs));

    final index = gateways.indexWhere(gateway.hasSameAddressAs);
    if (index == -1) {
      gateways.add(gateway);
    } else {
      gateways[index] = gateway;
    }

    await _write(prefs, gateways);
  }

  @override
  Future<void> update(GatewayInfo original, GatewayInfo updated) async {
    final prefs = await SharedPreferences.getInstance();
    final gateways = _decode(_readRaw(prefs));

    final originalIndex = gateways.indexWhere(original.hasSameAddressAs);

    for (var i = 0; i < gateways.length; i++) {
      if (i != originalIndex && gateways[i].hasSameAddressAs(updated)) {
        throw DuplicateGatewayException(updated);
      }
    }

    if (originalIndex == -1) {
      gateways.add(updated);
    } else {
      gateways[originalIndex] = updated;
    }

    await _write(prefs, gateways);
  }

  @override
  Future<void> delete(GatewayInfo gateway) async {
    final prefs = await SharedPreferences.getInstance();
    final gateways = _decode(_readRaw(prefs));

    gateways.removeWhere(gateway.hasSameAddressAs);

    await _write(prefs, gateways);
  }

  String? _readRaw(SharedPreferences prefs) {
    try {
      return prefs.getString(storageKey);
    } catch (_) {
      return null;
    }
  }

  List<GatewayInfo> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return [];
    }
    if (decoded is! List) return [];

    final gateways = <GatewayInfo>[];
    for (final item in decoded) {
      final gateway = _tryParse(item);
      if (gateway != null && !gateways.any(gateway.hasSameAddressAs)) {
        gateways.add(gateway);
      }
    }
    return gateways;
  }

  GatewayInfo? _tryParse(Object? item) {
    try {
      return GatewayInfo.fromJson(item);
    } on FormatException {
      return null;
    }
  }

  Future<void> _write(
      SharedPreferences prefs,
      List<GatewayInfo> gateways,
      ) async {
    final raw = jsonEncode(gateways.map((g) => g.toJson()).toList());
    await prefs.setString(storageKey, raw);
  }
}