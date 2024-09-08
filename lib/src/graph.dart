import 'package:graphs/graphs.dart';

///Graph class
///
/// Made to be used with Graph dart library
class Graph {
  Map<String, Set<String>> nodes;
  Graph({
    required this.nodes,
  });

  void addNodes(Map<String, Set<String>> graph) {
    nodes.addAll(graph);
  }

  void addEdge(String v1, String v2) {
    if (nodes[v1] == null) {
      nodes[v1] = {v2};
    } else {
      nodes[v1]!.add(v2);
    }
    if (nodes[v2] == null) {
      nodes[v2] = {v1};
    } else {
      nodes[v2]!.add(v1);
    }
  }

  void removeEdge(String v1, String v2) {
    nodes[v1]?.remove(v2);
    nodes[v2]?.remove(v1);
  }

  Iterable<String>? findShortestPath(String start, String target) {
    return shortestPath(start, target, (node) => (nodes[node]!));
  }

  @override
  String toString() {
    var str = "";
    for (var key in nodes.keys) {
      str += "$key: ";
      str += "${nodes[key]}\n";
    }
    return str;
  }
}
