class PageModel {
  final String id;
  final String title;
  final String content;

  PageModel({
    required this.id,
    required this.title,
    this.content = '',
  });

  PageModel copyWith({
    String? id,
    String? title,
    String? content,
  }) {
    return PageModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}
