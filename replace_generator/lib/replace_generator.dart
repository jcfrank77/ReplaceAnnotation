import "package:build/build.dart";
import "package:source_gen/source_gen.dart";

import "src/replace_generator.dart";

// https://stackoverflow.com/a/56979721/83370
Builder replaceBuilder(BuilderOptions options) => ReplaceGenerator();
    // LibraryBuilder(ReplaceGenerator(), generatedExtension: ".active.g.dart");
