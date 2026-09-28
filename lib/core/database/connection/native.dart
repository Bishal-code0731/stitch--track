import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Android/iOS/desktop: an on-disk SQLite file opened on a background isolate.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'stitchtrack.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
