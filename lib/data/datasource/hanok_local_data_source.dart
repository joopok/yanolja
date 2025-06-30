import 'package:yanolja_clone/data/model/hanok_model.dart';

class HanokLocalDataSource {
  final List<Hanok> _hanoks = [
    Hanok(
      name: 'Gyeonggi Traditional House',
      region: 'Gyeonggi-do',
      description:
          'A beautiful hanok with a simple and elegant style, typical of the Gyeonggi region. Features a spacious courtyard and minimalist design.',
      imageUrl: 'https://source.unsplash.com/random/800x600?hanok,korea,traditional,house',
      styleTags: ['minimalist', 'elegant', 'courtyard'],
    ),
    Hanok(
      name: 'Jeolla Art House',
      region: 'Jeolla-do',
      description:
          "Known for its artistic flair, this hanok in Jeolla boasts a stunning garden and intricate wood carvings, reflecting the region's rich cultural heritage.",
      imageUrl: 'https://source.unsplash.com/random/800x601?hanok,korea,traditional,house',
      styleTags: ['artistic', 'garden', 'wood-carvings'],
    ),
    Hanok(
      name: 'Gyeongsang Noble House',
      region: 'Gyeongsang-do',
      description:
          'This hanok represents the dignified and scholarly spirit of the Gyeongsang region. It features a large library and a quiet, contemplative atmosphere.',
      imageUrl: 'https://source.unsplash.com/random/800x602?hanok,korea,traditional,house',
      styleTags: ['scholarly', 'dignified', 'library'],
    ),
    Hanok(
      name: 'Jeju Stone House',
      region: 'Jeju-do',
      description:
          'A unique hanok built with volcanic stone, characteristic of Jeju Island. It is designed to withstand strong winds and has a cozy, rustic charm.',
      imageUrl: 'https://source.unsplash.com/random/800x603?hanok,korea,traditional,house',
      styleTags: ['stone-wall', 'rustic', 'wind-resistant'],
    ),
    Hanok(
      name: 'Gangwon Mountain Retreat',
      region: 'Gangwon-do',
      description:
          'Nestled in the mountains, this hanok offers a peaceful escape. Its design harmonizes with nature, featuring large windows with scenic views.',
      imageUrl: 'https://source.unsplash.com/random/800x604?hanok,korea,traditional,house',
      styleTags: ['mountain-view', 'nature', 'peaceful'],
    ),
    Hanok(
      name: 'Chungcheong Lake House',
      region: 'Chungcheong-do',
      description:
          'A serene hanok located by a lake, offering a picturesque and tranquil setting. Ideal for meditation and relaxation.',
      imageUrl: 'https://source.unsplash.com/random/800x605?hanok,korea,traditional,house',
      styleTags: ['lake-view', 'serene', 'meditation'],
    ),
  ];

  Future<List<Hanok>> getHanoks() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return _hanoks;
  }
}