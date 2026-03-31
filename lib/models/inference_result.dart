class InferenceResult {
  final String label;
  final String output;

  const InferenceResult({
    required this.label,
    required this.output,
  });

  @override
  String toString() => 'InferenceResult(label: $label, output: $output)';
}