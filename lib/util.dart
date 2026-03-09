int roundScore(int value) {
  return ((value + 99) ~/ 100) * 100;
}

int roundFu(int fu) {
  return ((fu + 9) ~/ 10) * 10;
}

extension MapEx<K> on Map<K, int> {
  int _update(K key, int value) {
    value = update(
      key,
      (c) => c + value,
      ifAbsent: () => value,
    );
    if (value < 0) {
      throw StateError('$value');
    } else if (value == 0) {
      remove(key);
    }
    return value;
  }

  int inc(K key, int value) => _update(key, value);

  int dec(K key, int value) => _update(key, -value);

  int get(K key, [int fallback = 0]) => this[key] ?? fallback;
}

extension IterableAppend<T> on Iterable<T> {
  Iterable<T> followedByOne(T item) sync* {
    yield* this;
    yield item;
  }
}
