import 'package:sqflite/sqflite.dart';
import 'package:yanolja_clone/data/datasource/review_database.dart';
import 'package:yanolja_clone/data/model/accommodation_review.dart';

class ReviewRepository {
  final ReviewDatabase _database;

  const ReviewRepository(this._database);

  Future<List<AccommodationReview>> getReviews(String accommodationId) async {
    final database = await _database.database;
    final rows = await database.query(
      ReviewDatabase.tableName,
      where: 'accommodation_id = ?',
      whereArgs: [accommodationId],
      orderBy: 'updated_at DESC',
    );
    return rows.map(AccommodationReview.fromDatabase).toList(growable: false);
  }

  Future<AccommodationReview?> getReview(String id) async {
    final database = await _database.database;
    final rows = await database.query(
      ReviewDatabase.tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AccommodationReview.fromDatabase(rows.first);
  }

  Future<void> saveReview(AccommodationReview review) async {
    final database = await _database.database;
    await database.insert(
      ReviewDatabase.tableName,
      review.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteReview(String id) async {
    final database = await _database.database;
    await database.delete(
      ReviewDatabase.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
