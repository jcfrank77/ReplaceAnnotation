import "package:build/build.dart";
import "package:source_gen/source_gen.dart";

import "src/mapping_builder.dart";

Builder mappingBuilder(BuilderOptions options) => MappingBuilder();
    // LibraryBuilder(MappingBuilder(), generatedExtension: ".mapping");
