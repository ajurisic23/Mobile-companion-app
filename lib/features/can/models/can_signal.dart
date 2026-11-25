class CanSignal {
  const CanSignal({
    required this.name,
    required this.tag,
    required this.type,
    required this.value,
    this.unit,
  });

  final String name;
  final String tag;
  final String type;
  final num value;
  final String? unit;
}