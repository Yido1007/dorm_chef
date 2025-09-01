String capFirstTr(String s) {
  final t = s.trim();
  if (t.isEmpty) return t;
  final runes = t.runes.toList();
  final first = String.fromCharCode(runes.first);
  final rest = String.fromCharCodes(runes.skip(1));
  final upperFirst =
      first == 'i'
          ? 'İ'
          : first == 'ı'
          ? 'I'
          : first.toUpperCase();
  return '$upperFirst$rest';
}
