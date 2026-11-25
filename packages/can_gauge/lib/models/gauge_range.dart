class GaugeRange {
  const GaugeRange({
    required this.min,
    required this.max,
  }) : assert(max > min);

  final double min;
  final double max;

  double normalize(double value) {
    return ((value - min) / (max - min))
        .clamp(0.0, 1.0)
        .toDouble();
  }
}