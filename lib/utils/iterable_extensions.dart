extension ListExtensions<T> on List<T> {
  List<List<T>> batch(int batchSize) {
    if (batchSize <= 0) {
      throw ArgumentError('batchSize must be greater than 0');
    }
    return [for (int i = 0; i < length; i += batchSize) sublist(i, i + batchSize > length ? length : i + batchSize)];
  }
}
