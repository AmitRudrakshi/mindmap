import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'dart:convert';

import 'package:mindmap/constants.dart';
import 'package:mindmap/mindmap_node_model.dart';
import 'package:mindmap/node_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MindMapNode rootNode;
  late Graph graph;
  late BuchheimWalkerConfiguration builder;
  final Map<int, Node> nodeMap = {};

  @override
  void initState() {
    super.initState();
    // Simulated API JSON data
    String jsonData = jsonEncode(Constants.data);
    rootNode = MindMapNode.fromJson(json.decode(jsonData));
    _rebuildGraph();
  }

  void _rebuildGraph() {
    graph = Graph()..isTree = true;
    nodeMap.clear();
    _addNodesRecursively(rootNode, null, graph);
    builder = BuchheimWalkerConfiguration()
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM
      ..siblingSeparation = 16
      ..levelSeparation = 32
      ..subtreeSeparation = 32;
    setState(() {});
  }

  void _addNodesRecursively(
    MindMapNode node,
    MindMapNode? parent,
    Graph graph,
  ) {
    final gNode = Node.Id(node.id);
    nodeMap[node.id] = gNode;
    graph.addNode(gNode);
    if (parent != null && parent.isExpanded) {
      graph.addEdge(nodeMap[parent.id]!, gNode);
    } else if (parent == null) {
      // Attach root node
    }

    if (node.isExpanded) {
      for (var child in node.children) {
        _addNodesRecursively(child, node, graph);
      }
    }
  }

  // Expand/collapse logic: When tapped, toggle node and rebuild
  void _onNodeTap(MindMapNode tappedNode) {
    setState(() {
      tappedNode.isExpanded = !tappedNode.isExpanded;
      if (!tappedNode.isExpanded) {
        // Collapse all descendants
        _collapseAll(tappedNode);
      }
      _rebuildGraph();
    });
  }

  void _collapseAll(MindMapNode node) {
    for (var child in node.children) {
      child.isExpanded = false;
      _collapseAll(child);
    }
  }

  // Utility to find node by id
  MindMapNode? _findNodeById(MindMapNode node, int id) {
    if (node.id == id) return node;
    for (var child in node.children) {
      final found = _findNodeById(child, id);
      if (found != null) return found;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Mind Map',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Flutter Mind Map',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey[800],
          elevation: 0,
        ),
        body: graph == null
            ? const Center(child: CircularProgressIndicator())
            : InteractiveViewer(
                constrained: false,
                minScale: 0.1,
                maxScale: 5.0,
                child: GraphView(
                  graph: graph,
                  algorithm: BuchheimWalkerAlgorithm(
                    builder,
                    TreeEdgeRenderer(builder),
                  ),
                  builder: (Node node) {
                    final id = node.key!.value as int;
                    final mindMapNode = _findNodeById(rootNode, id)!;
                    return NodeWidget(
                      node: mindMapNode,
                      rootNode: rootNode,
                      onTap: () => _onNodeTap(mindMapNode),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
