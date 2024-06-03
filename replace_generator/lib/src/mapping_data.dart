import "constants.dart";

class MappingData {
  MappingData({
    required this.clazz,
    this.isDefault = false,
    this.path = "",
  });

  factory MappingData.fromString(String contents) {
    String? clazz;
    bool isDefault = false;
    String path = "";

    final List<String> lines = contents.split("\n");
    lines.forEach((String line) {
      final List<String> parts = line.split(":");
      if (parts.length != 2) {
        return;
      }

      final String key = parts[0];
      final String value = parts[1];

      if (key == clazzKey) {
        clazz = value;
        return;
      }

      if (key == isDefaultKey) {
        isDefault = value == "true";
        return;
      }

      if (key == pathKey) {
        path = value;
      }
    });

    if (clazz == null) {
      throw ArgumentError("No class found in mapping data.");
    }

    return MappingData(clazz: clazz!, isDefault: isDefault, path: path);
  }

  String clazz;
  bool isDefault;
  String path;
}
