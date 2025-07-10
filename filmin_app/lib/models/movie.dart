class MovieModel {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final bool adult;
  final bool video;
  final List<int> genreIds;
  final String originalLanguage;
  final double popularity;

  MovieModel({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.adult,
    required this.video,
    required this.genreIds,
    required this.originalLanguage,
    required this.popularity,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'],
      title: json['title'],
      originalTitle: json['original_title'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      adult: json['adult'] ?? false,
      video: json['video'] ?? false,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      originalLanguage: json['original_language'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_title': originalTitle,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'adult': adult,
      'video': video,
      'genre_ids': genreIds,
      'original_language': originalLanguage,
      'popularity': popularity,
    };
  }
}
