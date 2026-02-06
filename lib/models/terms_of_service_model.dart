class TermsOfServiceModel {
  final int id;
  final String title;
  final String content;
  final String? updatedAt;
  final TermsCreator? createdBy;

  TermsOfServiceModel({
    required this.id,
    required this.title,
    required this.content,
    this.updatedAt,
    this.createdBy,
  });

  factory TermsOfServiceModel.fromJson(Map<String, dynamic> json) {
    return TermsOfServiceModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
      createdBy: json['created_by'] != null
          ? TermsCreator.fromJson(
              Map<String, dynamic>.from(json['created_by']),
            )
          : null,
    );
  }
}

class TermsCreator {
  final int id;
  final String username;

  TermsCreator({
    required this.id,
    required this.username,
  });

  factory TermsCreator.fromJson(Map<String, dynamic> json) {
    return TermsCreator(
      id: json['id'] ?? 0,
      username: json['username']?.toString() ?? '',
    );
  }
}
