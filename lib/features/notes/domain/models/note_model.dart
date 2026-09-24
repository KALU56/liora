import 'note_page.dart';

class NoteModel {
  final String id;
  final String title;
  final int _storedPageCount;
  final List<NotePage> pages;
  final DateTime modifiedDate;
  final DateTime createdDate;
  final String? thumbnailPath;

  const NoteModel({
    required this.id,
    required this.title,
    int pageCount = 1,
    List<NotePage>? pages,
    required this.modifiedDate,
    required this.createdDate,
    this.thumbnailPath,
  }) : _storedPageCount = pageCount,
       pages = pages ?? const [];

  /// Supports legacy notes while always reporting the real count for pages
  /// that have been loaded from storage.
  int get pageCount => pages.isEmpty ? _storedPageCount : pages.length;

  NoteModel copyWith({
    String? id,
    String? title,
    int? pageCount,
    List<NotePage>? pages,
    DateTime? modifiedDate,
    DateTime? createdDate,
    String? thumbnailPath,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      pageCount: pageCount ?? this.pageCount,
      pages: pages ?? this.pages,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      createdDate: createdDate ?? this.createdDate,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

}
