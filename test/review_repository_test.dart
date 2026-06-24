import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yanolja_clone/data/datasource/review_database.dart';
import 'package:yanolja_clone/data/model/accommodation_review.dart';
import 'package:yanolja_clone/data/repository/review_repository.dart';

void main() {
  sqfliteFfiInit();

  late ReviewDatabase database;
  late ReviewRepository repository;

  setUp(() {
    database = ReviewDatabase(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    repository = ReviewRepository(database);
  });

  tearDown(() => database.close());

  test('saves, updates, reads, and deletes a review in SQLite', () async {
    final createdAt = DateTime(2026, 6, 24, 10);
    final review = AccommodationReview(
      id: 'review-1',
      accommodationId: 'hotel-1',
      authorId: 'guest@nol.com',
      authorName: 'NOL러',
      title: '도심 여행에 좋은 숙소',
      comment: '객실이 깨끗하고 직원 응대가 빨라서 편하게 머물렀습니다.',
      rating: 4.5,
      tripType: '친구와',
      recommended: true,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    await repository.saveReview(review);
    var stored = await repository.getReviews('hotel-1');

    expect(stored, hasLength(1));
    expect(stored.single.title, review.title);
    expect(stored.single.recommended, isTrue);

    await repository.saveReview(
      review.copyWith(
        title: '수정된 후기',
        rating: 5,
        updatedAt: createdAt.add(const Duration(minutes: 5)),
      ),
    );
    stored = await repository.getReviews('hotel-1');

    expect(stored, hasLength(1));
    expect(stored.single.title, '수정된 후기');
    expect(stored.single.rating, 5);

    await repository.deleteReview(review.id);
    expect(await repository.getReviews('hotel-1'), isEmpty);
  });
}
