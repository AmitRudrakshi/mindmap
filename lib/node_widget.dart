import 'package:flutter/material.dart';
import 'package:mindmap/mindmap_node_model.dart';

class NodeWidget extends StatelessWidget {
  final MindMapNode node;
  final MindMapNode rootNode;
  final VoidCallback? onTap;

  const NodeWidget({
    Key? key,
    required this.node,
    required this.rootNode,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.children.isNotEmpty;
    final isRoot = node.id == rootNode.id;

    Color getNodeColor() {
      if (isRoot) return Colors.red[300]!;
      if (hasChildren) {
        return node.isExpanded ? Colors.teal[300]! : Colors.blueGrey[300]!;
      }
      return Colors.amber[300]!;
    }

    return GestureDetector(
      onTap: hasChildren ? onTap : null,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: getNodeColor(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (node.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    node.image!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              if (node.image != null) const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    node.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (hasChildren) const SizedBox(width: 4),
                  if (hasChildren)
                    Icon(
                      node.isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: Colors.white,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
