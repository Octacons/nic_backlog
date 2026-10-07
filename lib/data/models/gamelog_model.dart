class GameLogModel {
  final String id;
  final String title;
  final String note;
  final DateTime date;
  final double? rating;

  GameLogModel({
    required this.id,
    required this.title,
    required this.note,
    required this.date,
    this.rating,
  });

  factory GameLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return GameLogModel(
      id: docId,
      title: map['title'] ?? '',
      note: map['note'] ?? '',
      date: DateTime.parse(map['date']),
      rating: (map['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'note': note,
      'date': date.toIso8601String(),
      'rating': rating,
    };
  }
}
