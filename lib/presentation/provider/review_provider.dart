import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/data/datasource/review_database.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/data/model/accommodation_review.dart';
import 'package:yanolja_clone/data/repository/review_repository.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';

final reviewDatabaseProvider = Provider<ReviewDatabase>((ref) {
  final database = ReviewDatabase();
  ref.onDispose(database.close);
  return database;
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(reviewDatabaseProvider));
});

final storedReviewsProvider =
    FutureProvider.family<List<AccommodationReview>, String>((ref, id) {
  return ref.watch(reviewRepositoryProvider).getReviews(id);
});

final reviewFeedProvider =
    FutureProvider.family<List<ReviewFeedItem>, String>((ref, id) async {
  final accommodation = await ref.watch(accommodationDetailProvider(id).future);
  final storedReviews = await ref.watch(storedReviewsProvider(id).future);

  final storedItems = storedReviews.map(ReviewFeedItem.fromStored);
  final mockItems = accommodation.reviews.map(
    (review) => ReviewFeedItem.fromMock(id, review),
  );
  return [...storedItems, ...mockItems];
});

final reviewActionsProvider = Provider<ReviewActions>((ref) {
  return ReviewActions(ref);
});

class ReviewActions {
  final Ref _ref;

  const ReviewActions(this._ref);

  Future<void> save(AccommodationReview review) async {
    await _ref.read(reviewRepositoryProvider).saveReview(review);
    _refresh(review.accommodationId);
  }

  Future<void> delete(AccommodationReview review) async {
    await _ref.read(reviewRepositoryProvider).deleteReview(review.id);
    _refresh(review.accommodationId);
  }

  void _refresh(String accommodationId) {
    _ref.invalidate(storedReviewsProvider(accommodationId));
    _ref.invalidate(reviewFeedProvider(accommodationId));
  }
}

class ReviewFeedItem {
  final String id;
  final String accommodationId;
  final String userName;
  final double rating;
  final String title;
  final String comment;
  final DateTime date;
  final String tripType;
  final bool recommended;
  final int likes;
  final int dislikes;
  final bool isEditable;
  final AccommodationReview? storedReview;

  const ReviewFeedItem({
    required this.id,
    required this.accommodationId,
    required this.userName,
    required this.rating,
    required this.title,
    required this.comment,
    required this.date,
    required this.tripType,
    required this.recommended,
    required this.likes,
    required this.dislikes,
    required this.isEditable,
    this.storedReview,
  });

  factory ReviewFeedItem.fromStored(AccommodationReview review) {
    return ReviewFeedItem(
      id: review.id,
      accommodationId: review.accommodationId,
      userName: review.authorName,
      rating: review.rating,
      title: review.title,
      comment: review.comment,
      date: review.updatedAt,
      tripType: review.tripType,
      recommended: review.recommended,
      likes: 0,
      dislikes: 0,
      isEditable: true,
      storedReview: review,
    );
  }

  factory ReviewFeedItem.fromMock(String accommodationId, Review review) {
    final trimmed = review.comment.trim();
    final title = trimmed.length > 24
        ? '${trimmed.substring(0, 24)}...'
        : trimmed.isEmpty
            ? '이용객 후기'
            : trimmed;
    return ReviewFeedItem(
      id: 'mock_${accommodationId}_${review.id}',
      accommodationId: accommodationId,
      userName: review.userName.isEmpty ? '실제 이용객' : review.userName,
      rating: review.rating,
      title: title,
      comment: review.comment,
      date: review.date,
      tripType: '숙박',
      recommended: review.rating >= 4,
      likes: review.likes,
      dislikes: review.dislikes,
      isEditable: false,
    );
  }
}
