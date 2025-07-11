class Party {
  final int id;
  final String name;
  final String oneLiner;
  final String category;
  final String imageUrl;

  Party({
    required this.id,
    required this.name,
    required this.oneLiner,
    required this.category,
    required this.imageUrl,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      name: json['name'],
      oneLiner: json['one_liner'],
      category: json['category'],
      imageUrl: json['image_url'],
    );
  }
}
