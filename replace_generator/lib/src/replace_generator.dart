import "dart:async";

import "package:build/build.dart";
import "package:glob/glob.dart";

import "mapping_data.dart";

class ReplaceGenerator implements Builder {
  @override
  final Map<String, List<String>> buildExtensions = const <String, List<String>>{
    "{{}}.mapping": <String>["{{}}.active.dart"]
  };

  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    // see if we are a default, otherwise move on
    final MappingData stepData =
        MappingData.fromString(await buildStep.readAsString(buildStep.inputId));
    if (!stepData.isDefault) {
      return "";
    }

    final Stream<AssetId> mappingFiles = buildStep.findAssets(Glob("**/*.mapping"));

    final List<MappingData> mappingData = <MappingData>[];
    await for (final AssetId mappingInfo in mappingFiles) {
      final String contents = await buildStep.readAsString(mappingInfo);
      final MappingData data = MappingData.fromString(contents);
      if (data.clazz != stepData.clazz) {
        continue;
      }

      mappingData.add(data);
    }

    if (mappingData.isEmpty) {
      return "";
    }

    // if there is more than a pair or replacements, throw error
    if (mappingData.length > 2) {
      throw ArgumentError("More than one replacement found for ${stepData.clazz}");
    }

    // if there is more than one default, throw error
    final List<MappingData> defaults = mappingData.where((MappingData d) => d.isDefault).toList();
    if (defaults.length > 1) {
      throw ArgumentError("More than one default found for ${stepData.clazz}");
    }

    // if there is no default, throw error
    if (defaults.isEmpty) {
      throw ArgumentError("No default found for ${stepData.clazz}");
    }

    // if there is only one mapping data, write that default to be active
    if (mappingData.length == 1) {
      // pendingFileReads += 1;
      final String fileContents =
          await buildStep.readAsString(AssetId(buildStep.inputId.package, stepData.path));
      buildStep.writeAsString(
          AssetId(buildStep.inputId.package, stepData.path.replaceFirst(".dart", ".active.dart")),
          fileContents);
      return "";
    }

    // else, need to find the data for the non-default entry
    final MappingData nonDefault = mappingData.firstWhere((MappingData d) => !d.isDefault);

    // pendingFileReads += 1;
    final String fileContents =
        await buildStep.readAsString(AssetId(buildStep.inputId.package, nonDefault.path));
    buildStep.writeAsString(
        AssetId(buildStep.inputId.package, stepData.path.replaceFirst(".dart", ".active.dart")),
        fileContents);
    return "";
  }
}
