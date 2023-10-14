const fs = require('fs')
const path = require('path')

const read = (dir, plugins, ignore = []) => {
  const results = {};
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const pluginKey in plugins) {
    results[pluginKey] = [];
  }
  for (const entry of entries) {
    if (entry.isDirectory()) {
      if (!ignore.includes(entry.name)) {
        const fullPath = path.join(dir, entry.name)
        const nestedResults = read(fullPath, plugins, ignore);
        for (const pluginKey in plugins) {
          results[pluginKey] = results[pluginKey].concat(nestedResults[pluginKey]);
        }
      }
    } else {
      if (!ignore.includes(entry.name)) {
        for (const pluginKey in plugins) {
          const matcher = plugins[pluginKey];
          const matchResult = matcher(dir, entry);
          if (matchResult) results[pluginKey].push(matchResult);
        }
      }
    }
  }
  return results;
};

function extractArgs(sqlContent) {
  const argMatch = sqlContent.match(/FUNCTION\s+[\w_]+\s*\(([\s\S]*?)\)/);
  if (argMatch) {
    const argsString = argMatch[1].trim();
    return argsString.split(',\n').map(arg => arg.trim());
  }
  return null;
}

const captureFunctions = (dir, entry) => {
  if (
    entry.name.endsWith('.sql') &&
    entry.name.split('.').length === 2
  ) {
    const fullPath = path.join(dir, entry.name);
    const name = path.basename(entry.name, '.sql');
    const content = fs.readFileSync(fullPath, 'utf8');
    console.log(extractArgs(content))
    const match = content.match(/-- depends: (\w+)/);
    const dependsOn = match ? match[1].split(',').map(v => v.trim()) : [];
    return { name, content, fullPath, dependsOn };
  }
  return null
};

const captureTests = (dir, entry) => {
  if (
    entry.name.endsWith('.sql') &&
    entry.name.split('.').length === 3 &&
    entry.name.split('.')[1].startsWith('test')
  )  {
    const fullPath = path.join(dir, entry.name);
    const content = fs.readFileSync(fullPath, 'utf8');
    return { name: entry.name, content, fullPath };
  }
  return null
};

const captureSnapshots = (dir, entry) => {
  if (
    entry.name.endsWith('.json') &&
    entry.name.split('.').length === 3 &&
    entry.name.startsWith('snapshot')
  )  {
    const fullPath = path.join(dir, entry.name);
    const content = fs.readFileSync(fullPath, 'utf8');
    return { name: entry.name, content, fullPath };
  }
};

module.exports = () => {
  return read('./', {
    functions: captureFunctions,
    tests: captureTests,
    snapshots: captureSnapshots
  }, [
    "script",
    "ignore",
    "actions",
    "node_modules",
    "package.json",
    "package-lock.json",
    "README.md",
    ".gitignore",
    ".git"
  ]);
}