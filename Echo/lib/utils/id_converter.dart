class IdConverter {
  // Converte qualquer ID para string (seja int, double ou string)
  static String toStringId(dynamic id) {
    if (id is int || id is double) {
      return id.toString();
    }
    return id as String;
  }

  // Converte string para int para APIs que esperam números
  static int toIntId(String stringId) {
    return int.parse(stringId);
  }
}
