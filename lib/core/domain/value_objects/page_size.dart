class PageSize {
  final double width;
  final double height;

  const PageSize(this.width, this.height);

  @override
  bool operator ==(Object other) {
    return other is PageSize && other.width == width && other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);
}
