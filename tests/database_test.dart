import 'package:flutter_test/flutter_test.dart';

import 'package:pictoword/database/app_database.dart';

void main() {
  test("Database creation", () async {
    final db = await AppDatabase.database;

    final result = await db.rawQuery("SELECT name FROM sqlite_master");

    expect(result.isNotEmpty, true);
  });
}
