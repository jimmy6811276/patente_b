/// Representative ministerial road-sign thumbnails for each chapter.
/// Filenames match bundled `assets/images/*.png` (same set as the web app).
abstract final class ChapterMedia {
  static const Map<int, String> thumbs = {
    1: '550.png',
    2: '1.png',
    3: '54.png',
    4: '97.png',
    5: '40.png',
    6: '502.png',
    7: '154.png',
    8: '184.png',
    9: '144.png',
    10: '121.png',
    11: '301.png',
    14: '642.png',
  };

  static String? assetPathFor(int chapterId) {
    final file = thumbs[chapterId];
    if (file == null) return null;
    return 'assets/images/$file';
  }
}

/// Cover art for Home practice grid tiles (`assets/tiles/*.jpg`).
abstract final class PracticeMedia {
  static const quiz = 'assets/tiles/tile_quiz.jpg';
  static const chapters = 'assets/tiles/tile_chapters.jpg';
  static const signs = 'assets/tiles/tile_signs.jpg';
  static const hard = 'assets/tiles/tile_hard.jpg';
  static const vocab = 'assets/tiles/tile_vocab.jpg';
  static const fastTrack = 'assets/tiles/tile_fast_track.jpg';
}
