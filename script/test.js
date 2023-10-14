const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
const read = require('./read')

const client = new Client({
  host: 'localhost',
  port: '28816',
  user: 'thomasreggi',
  password: '',
  database: 'json_schema_3'
});

const { tests } = read();

async function runTests() {
  await client.connect();

  for (const test of tests) {
    const functionName = test.name.split('.')[0]
    const testName = test.name.split('.')[1]
    const snapshotFile = `${functionName}/snapshot.${testName}.json`;
    
    let existingSnapshot = null;
    if (fs.existsSync(snapshotFile)) {
      existingSnapshot = JSON.parse(fs.readFileSync(snapshotFile, 'utf8'));
    }
    
    const res = await client.query(test.content);
    const resultJSON = JSON.stringify(res.rows);
    // console.log(resultJSON)

    if (existingSnapshot) {
      if (JSON.stringify(existingSnapshot) !== resultJSON) {
        console.log(JSON.stringify(existingSnapshot, null, 2))
        console.log(JSON.stringify(JSON.parse(resultJSON), null, 2))
        await client.end();
        throw new Error(`Snapshot mismatch for ${test.name}`);
      }
      // fs.writeFileSync(snapshotFile, JSON.stringify(JSON.parse(resultJSON), null, 2));
    } else {
      fs.writeFileSync(snapshotFile, JSON.stringify(JSON.parse(resultJSON), null, 2));
    }
  }

  await client.end();
}

runTests().catch(err => console.error(err));
