import 'dart:io';

void main() {
  var dir = Directory('d:/nas/12123/lib');
  processDirectory(dir);
}

void processDirectory(Directory dir) {
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      if (content.contains("import 'package:vibrate/vibrate.dart';")) {
        content = content.replaceAll(
          "import 'package:vibrate/vibrate.dart';",
          "import 'package:dsm_helper/util/function.dart';",
        );
        entity.writeAsStringSync(content);
        print('Processed ${entity.path}');
      }
    }
  }
}
