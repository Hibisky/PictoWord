class DatabaseTables {

static const themes = '''
CREATE TABLE themes(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
description TEXT,
icon TEXT
)
''';


static const levels = '''
CREATE TABLE levels(
id INTEGER PRIMARY KEY AUTOINCREMENT,
theme_id INTEGER,
name TEXT,
difficulty INTEGER
)
''';


static const questions = '''
CREATE TABLE questions(
id INTEGER PRIMARY KEY AUTOINCREMENT,
level_id INTEGER,
image_path TEXT,
correct_answer TEXT,
difficulty INTEGER,
explanation TEXT
)
''';


static const words = '''
CREATE TABLE words(
id INTEGER PRIMARY KEY AUTOINCREMENT,
theme_id INTEGER,
word TEXT,
category TEXT,
difficulty INTEGER
)
''';


}