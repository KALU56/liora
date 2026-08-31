class NoteModel {
  final String id;
  final String title;
  final int pageCount;
  final DateTime modifiedDate;
  final DateTime createdDate;
  final String? thumbnailPath;

  const NoteModel({
    required this.id,
    required this.title,
    this.pageCount = 1,
    required this.modifiedDate,
    required this.createdDate,
    this.thumbnailPath,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    int? pageCount,
    DateTime? modifiedDate,
    DateTime? createdDate,
    String? thumbnailPath,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      pageCount: pageCount ?? this.pageCount,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      createdDate: createdDate ?? this.createdDate,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'pageCount': pageCount,
      'modifiedDate': modifiedDate.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'thumbnailPath': thumbnailPath,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      pageCount: map['pageCount'] as int? ?? 1,
      modifiedDate: DateTime.parse(map['modifiedDate'] as String),
      createdDate: DateTime.parse(map['createdDate'] as String),
      thumbnailPath: map['thumbnailPath'] as String?,
    );
  }
}
