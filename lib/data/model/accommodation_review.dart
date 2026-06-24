class AccommodationReview {
  final String id;
  final String accommodationId;
  final String authorId;
  final String authorName;
  final String title;
  final String comment;
  final double rating;
  final String tripType;
  final bool recommended;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccommodationReview({
    required this.id,
    required this.accommodationId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.comment,
    required this.rating,
    required this.tripType,
    required this.recommended,
    required this.createdAt,
    required this.updatedAt,
  });

  AccommodationReview copyWith({
    String? title,
    String? comment,
    double? rating,
    String? tripType,
    bool? recommended,
    DateTime? updatedAt,
  }) {
    return AccommodationReview(
      id: id,
      accommodationId: accommodationId,
      authorId: authorId,
      authorName: authorName,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      tripType: tripType ?? this.tripType,
      recommended: recommended ?? this.recommended,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AccommodationReview.fromDatabase(Map<String, Object?> map) {
    return AccommodationReview(
      id: map['id']! as String,
      accommodationId: map['accommodation_id']! as String,
      authorId: map['author_id']! as String,
      authorName: map['author_name']! as String,
      title: map['title']! as String,
      comment: map['comment']! as String,
      rating: (map['rating']! as num).toDouble(),
      tripType: map['trip_type']! as String,
      recommended: (map['recommended']! as int) == 1,
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }

  Map<String, Object?> toDatabase() {
    return {
      'id': id,
      'accommodation_id': accommodationId,
      'author_id': authorId,
      'author_name': authorName,
      'title': title,
      'comment': comment,
      'rating': rating,
      'trip_type': tripType,
      'recommended': recommended ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
