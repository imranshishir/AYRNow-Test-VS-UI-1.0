/// Paginated response from backend: content, page, size, totalElements, totalPages, first, last
class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  const PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final contentRaw = json['content'] as List? ?? [];
    return PageResponse(
      content: contentRaw.map((e) => fromJsonT(e)).toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
    );
  }

  bool get hasMore => !last;
}
