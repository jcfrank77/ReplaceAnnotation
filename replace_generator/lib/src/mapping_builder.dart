import "dart:async";

import "package:build/build.dart";
import "package:replace_annotation/replace_annotation.dart";
import "package:source_gen/source_gen.dart";

import "constants.dart";

class MappingBuilder extends Builder {
  @override
  final Map<String, List<String>> buildExtensions = const <String, List<String>>{
    ".dart": <String>[".mapping"]
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final Resolver resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    final LibraryReader library = LibraryReader(await buildStep.inputLibrary);
    const TypeChecker replaceAnnotation = TypeChecker.fromRuntime(Replace);

    final List<AnnotatedElement> annotated = library.annotatedWith(replaceAnnotation).toList();

    if (annotated.isEmpty) {
      return;
    }

    if (annotated.length > 1) {
      throw InvalidGenerationSourceError(
          "More than one class annotated with @ReplaceAnnotation found.");
    }

    final ConstantReader reader = annotated.first.annotation;

    final String fullPath = library.element.source.fullName;
    final int libIndex = fullPath.indexOf("/lib/");
    final String relPath = fullPath.substring(libIndex + 1);

    String mapping = "";
    mapping += "$clazzKey:${library.element.exportNamespace.definedNames.keys.first}";
    mapping += "\n$isDefaultKey:${reader.read('isDefault').boolValue}";
    mapping += "\n$pathKey:$relPath";
    mapping += "\n";

    if (annotated.isEmpty) {
      return;
    }

    buildStep.writeAsString(buildStep.inputId.changeExtension(".mapping"), mapping);
  }
}
