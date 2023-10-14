const topologicalSort = (nodes) => {
  let sorted = [];
  let visited = new Set();
  let visiting = new Set();

  const visit = (node) => {
    if (visited.has(node.name)) return;
    if (visiting.has(node.name)) throw new Error('Circular dependency');

    visiting.add(node.name);

    if (Array.isArray(node.dependsOn)) {
      node.dependsOn.forEach((dependency) => {
        if (nodes[dependency]) visit(nodes[dependency]);
      });
    }

    visited.add(node.name);
    visiting.delete(node.name);
    sorted.push(node);
  };

  Object.values(nodes).forEach((node) => {
    if (!visited.has(node.name)) {
      visit(node);
    }
  });

  return sorted;
};

module.exports = topologicalSort;