Future<void> main() async {
  final stream = Stream.fromIterable([1, 2, 3, 4, 5]);

  final result = stream
      .map((n) => n * n)        // square
      .where((n) => n.isEven);  // keep even

  await for (final value in result) {
    print(value);
  }
}