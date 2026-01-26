extension ListExtension<T> on List<T> {
  T? tryGet(int index) => index < 0 || index >= length ? null : this[index];

  Map<int, T> toMap() {
    return {
      for (int i = 0; i < length; i++) i: this[i],
    };
  }

  void addIfNotNull(T? value) {
    if (value != null) {
      add(value);
    }
  }

  List<T> reversedIf(bool reverse) {
    return reverse ? reversed.toList() : this;
  }
}
