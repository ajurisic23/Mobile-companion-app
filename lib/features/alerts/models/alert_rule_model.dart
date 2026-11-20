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

// mozda ce i trebati atribut za can, al to cemo da vidimo u kom obliku se vracaju podaci :D
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

}