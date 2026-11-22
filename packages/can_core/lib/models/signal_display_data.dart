class SignalDisplayData {
  const SignalDisplayData({
    required this.tag,
    required this.name,
    required this.value,
    this.unit,
  });

  final String tag;
  final String name;
  final String value;
  final String? unit;
}
