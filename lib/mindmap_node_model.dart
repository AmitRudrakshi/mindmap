class MindMapNode {
  final int id;
  final String name;
  final String? image;
  final List<MindMapNode> children;
  bool isExpanded;

  MindMapNode({
    required this.id,
    required this.name,
    this.image,
    required this.children,
    this.isExpanded = true,
  });

  factory MindMapNode.fromJson(Map<String, dynamic> json) {
    return MindMapNode(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      children: json['children'] != null
          ? (json['children'] as List)
                .map((child) => MindMapNode.fromJson(child))
                .toList()
          : [],
      isExpanded: true,
    );
  }
}
