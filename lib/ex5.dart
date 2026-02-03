class Settings {
  static final Settings _instance = Settings._internal();

  Settings._internal();

  factory Settings() {
    return _instance;
  }

  String theme = 'light';
}

void main() {
  final a = Settings();
  final b = Settings();

  print(identical(a, b)); // true

  a.theme = 'dark';
  print(b.theme); // dark
}