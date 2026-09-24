class ArgbColor {
  final int value;

  const ArgbColor(this.value);

  int get alpha => (value >> 24) & 0xFF;

  @override
  bool operator ==(Object other) => other is ArgbColor && other.value == value;

  @override
  int get hashCode => value;
}
