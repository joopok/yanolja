// 실제 서버 대신 사용할 가상 데이터 소스
class MockAccommodationApi {
  // 실제 DB가 없으므로, 하드코딩된 데이터 리스트를 사용합니다.
  final List<Map<String, dynamic>> _mockData = [
    {
      'id': '1',
      'name': '강남 부티크 호텔',
      'address': '서울시 강남구',
      'price': 150000,
      'rating': 4.8,
      'imageUrls': ['https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8JUVDJTk4JUI4JUVDJTg1JThDfGVufDB8fDB8fHww'],
      'description':
          '강남역 5분 거리에 위치한 최고의 부티크 호텔입니다. 모던한 인테리어와 최상의 서비스로 편안한 휴식을 제공합니다.'
    },
    {
      'id': '2',
      'name': '해운대 오션뷰 펜션',
      'address': '부산시 해운대구',
      'price': 220000,
      'rating': 4.9,
      'imageUrls': ['https://images.unsplash.com/photo-1540541338287-41700207dee6?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8JUVDJTk4JUI4JUVDJTg1JThDfGVufDB8fDB8fHww'],
      'description':
          '눈 앞에 펼쳐진 해운대 바다를 감상할 수 있는 오션뷰 펜션입니다. 파도 소리와 함께 로맨틱한 하룻밤을 보내세요.'
    },
    {
      'id': '3',
      'name': '제주 돌담길 감성 숙소',
      'address': '제주시 애월읍',
      'price': 180000,
      'rating': 4.7,
      'imageUrls': ['https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fCVFQyU5OCVCOCVFQyU4NSU4Q3xlbnwwfHwwfHx8MA%3D%3D'],
      'description':
          '제주 전통 돌담길 옆에 위치한 감성 가득한 숙소입니다. 조용한 분위기 속에서 완벽한 힐링을 경험할 수 있습니다.'
    },
    {
      'id': '4',
      'name': '경주 한옥 스테이',
      'address': '경상북도 경주시',
      'price': 130000,
      'rating': 4.6,
      'imageUrls': ['https://images.unsplash.com/photo-1582719508461-905c673771fd?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fCVFQyU5OCVCOCVFQyU4NSU4Q3xlbnwwfHwwfHx8MA%3D%3D'],
      'description':
          '천년 고도 경주의 역사를 느낄 수 있는 고즈넉한 한옥 스테이입니다. 황리단길과 가까워 여행하기 좋습니다.'
    },
  ];

  // 모든 숙소 목록을 비동기적으로 가져옵니다. (네트워크 통신 흉내)
  Future<List<Map<String, dynamic>>> fetchAccommodations() async {
    await Future.delayed(const Duration(seconds: 1)); // 1초 딜레이
    return _mockData;
  }

  // ID로 특정 숙소 하나를 가져옵니다.
  Future<Map<String, dynamic>> fetchAccommodationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 0.5초 딜레이
    return _mockData.firstWhere((element) => element['id'] == id);
  }
}
