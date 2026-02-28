const mongoose = require('mongoose');
const fs = require('fs');

function loadEnvLocal(path = '.env.local') {
  if (!fs.existsSync(path)) return;
  const lines = fs.readFileSync(path, 'utf8').split('\n');
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eq = trimmed.indexOf('=');
    if (eq <= 0) continue;
    const key = trimmed.slice(0, eq).trim();
    const value = trimmed.slice(eq + 1).trim();
    if (!process.env[key]) {
      process.env[key] = value;
    }
  }
}

async function run() {
  loadEnvLocal();

  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error('Missing MONGODB_URI in .env.local');
    process.exit(1);
  }

  await mongoose.connect(uri, { serverSelectionTimeoutMS: 10000 });
  const db = mongoose.connection.db;

  const collections = await db.listCollections({}, { nameOnly: true }).toArray();
  const names = collections.map((c) => c.name);

  let sample = null;
  for (const preferred of ['questions', 'grades', 'microskills']) {
    if (names.includes(preferred)) {
      sample = await db.collection(preferred).find({}).limit(1).toArray();
      if (sample.length > 0) break;
    }
  }

  if (!sample || sample.length === 0) {
    for (const name of names) {
      sample = await db.collection(name).find({}).limit(1).toArray();
      if (sample.length > 0) break;
    }
  }

  console.log({
    ok: true,
    database: db.databaseName,
    collections: names,
    sample: sample || [],
  });
}

run()
  .catch((error) => {
    console.error({
      ok: false,
      message: error?.message || String(error),
      code: error?.code || null,
    });
    process.exit(1);
  })
  .finally(async () => {
    try {
      await mongoose.connection.close();
    } catch {}
  });
