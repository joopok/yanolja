import 'package:sqflite/sqflite.dart' as sqflite;

class ReviewDatabase {
  static const String tableName = 'accommodation_reviews';

  final sqflite.DatabaseFactory _databaseFactory;
  final String? _databasePath;
  sqflite.Database? _database;

  ReviewDatabase({
    sqflite.DatabaseFactory? factory,
    String? databasePath,
  })  : _databaseFactory = factory ?? sqflite.databaseFactory,
        _databasePath = databasePath;

  Future<sqflite.Database> get database async {
    final current = _database;
    if (current != null && current.isOpen) return current;

    final path = _databasePath ??
        '${await sqflite.getDatabasesPath()}/yanolja_reviews.db';
    _database = await _databaseFactory.openDatabase(
      path,
      options: sqflite.OpenDatabaseOptions(
        version: 1,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE $tableName (
              id TEXT PRIMARY KEY,
              accommodation_id TEXT NOT NULL,
              author_id TEXT NOT NULL,
              author_name TEXT NOT NULL,
              title TEXT NOT NULL,
              comment TEXT NOT NULL,
              rating REAL NOT NULL,
              trip_type TEXT NOT NULL,
              recommended INTEGER NOT NULL DEFAULT 1,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          await database.execute('''
            CREATE INDEX reviews_accommodation_updated_idx
            ON $tableName (accommodation_id, updated_at DESC)
          ''');
        },
      ),
    );
    return _database!;
  }

  Future<void> close() async {
    final current = _database;
    if (current != null && current.isOpen) {
      await current.close();
    }
    _database = null;
  }
}
