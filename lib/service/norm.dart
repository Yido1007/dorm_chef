String norm(String v) {
  return v
      .trim()
      .replaceAll('İ', 'i')
      .replaceAll('I', 'ı')
      .replaceAll('Ş', 'ş')
      .replaceAll('Ğ', 'ğ')
      .replaceAll('Ü', 'ü')
      .replaceAll('Ö', 'ö')
      .replaceAll('Ç', 'ç')
      .toLowerCase();
}
