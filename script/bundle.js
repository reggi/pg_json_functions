const fs = require('fs');
const path = require('path');
const read = require('./read');
const topologicalSort = require('./sort');

const { functions } = read();
const sortedFiles = topologicalSort(functions);
const finalSQL = sortedFiles.map((file) => file.content).join('\n\n');

fs.writeFileSync('./actions/bundle.sql', finalSQL);

const resetSQLContent = sortedFiles.map((file) => `SELECT remove_function('${file.name}');`).join('\n');
fs.writeFileSync('./actions/reset.sql', resetSQLContent);
