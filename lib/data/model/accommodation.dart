// 숙소 데이터 구조를 정의하는 모델 클래스
class Accommodation {
  final String id;
  final String name;
  final String address;
  final int price;
  final double rating;
  final List<String> imageUrls;
  final String description;

  Accommodation({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
    required this.rating,
    required this.imageUrls,
    required this.description,
  });

  factory Accommodation.fromMap(Map<String, dynamic> map) {
    return Accommodation(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      price: map['price'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      description: map['description'] ?? '상세 설명이 없습니다.',
    );
  }
}
