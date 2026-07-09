import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'database_tables.dart';


class AppDatabase {


static Database? _database;


static Future<Database> get database async{

if(_database != null){
return _database!;
}


_database = await _initDatabase();

return _database!;

}



static Future<Database> _initDatabase() async{


final path = join(
await getDatabasesPath(),
'pictoword.db'
);



return openDatabase(
path,
version:1,

onCreate:(db,version) async{


await db.execute(
DatabaseTables.themes
);

await db.execute(
DatabaseTables.levels
);

await db.execute(
DatabaseTables.questions
);

await db.execute(
DatabaseTables.words
);


});


}


}