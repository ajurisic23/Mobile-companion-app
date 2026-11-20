enum AlertOperator {
  greaterThan,
  greaterThanOrEqual,
  lessThan,
  lessThanOrEqual,
  equal,
  notEqual,
}

enum AlertSeverity {
  info,
  warning,
  critical,
}

class AlertRule {
  final String id;
  final String gatewayId;
  final String signalName;
  final AlertOperator operator;
  final double threshold;
  final int durationMs;
  final double hysteresis;
  final AlertSeverity severity;
  final bool isEnabled;

  const AlertRule({
    required this.id,
    required this.gatewayId,
    required this.signalName,
    required this.operator,
    required this.threshold,
    this.durationMs = 0,
    this.hysteresis = 0,
    this.severity = AlertSeverity.warning,
    this.isEnabled = true,
  });

  AlertRule copyWith({
    String? id,
    String? gatewayId,
    String? signalName,
    AlertOperator? operator,
    double? threshold,
    int? durationMs,
    double? hysteresis,
    AlertSeverity? severity,
    bool? isEnabled,
  }) {
    return AlertRule(
      id: id ?? this.id,
      gatewayId: gatewayId ?? this.gatewayId,
      signalName: signalName ?? this.signalName,
      operator: operator ?? this.operator,
      threshold: threshold ?? this.threshold,
      durationMs: durationMs ?? this.durationMs,
      hysteresis: hysteresis ?? this.hysteresis,
      severity: severity ?? this.severity,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gatewayId': gatewayId,
      'signalName': signalName,
      'operator': operator.name,
      'threshold': threshold,
      'durationMs': durationMs,
      'hysteresis': hysteresis,
      'severity': severity.name,
      'isEnabled': isEnabled,
    };
  }

  factory AlertRule.fromJson(Map<String, dynamic> json) {
    return AlertRule(
      id: json['id'] as String,
      gatewayId: json['gatewayId'] as String,
      signalName: json['signalName'] as String,
      operator: AlertOperator.values.byName(json['operator'] as String),
      threshold: (json['threshold'] as num).toDouble(),
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      hysteresis: (json['hysteresis'] as num?)?.toDouble() ?? 0,
      severity: AlertSeverity.values.byName(
        (json['severity'] as String?) ?? AlertSeverity.warning.name,
      ),
      isEnabled: (json['isEnabled'] as bool?) ?? true,
    );
  }
}