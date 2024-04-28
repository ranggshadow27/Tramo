class Utils {
  static int formatRawApiValue(String rawValue) {
    return int.parse(rawValue.replaceAll(".", ""));
  }
}
