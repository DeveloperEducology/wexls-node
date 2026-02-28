#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

function loadEnvLocal(file = '.env.local') {
  if (!fs.existsSync(file)) return;
  const lines = fs.readFileSync(file, 'utf8').split('\n');
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const idx = trimmed.indexOf('=');
    if (idx <= 0) continue;
    const key = trimmed.slice(0, idx).trim();
    const value = trimmed.slice(idx + 1).trim();
    if (!process.env[key]) process.env[key] = value;
  }
}

function parseArgs(argv) {
  const out = { file: '', microskillId: '' };
  for (let i = 2; i < argv.length; i += 1) {
    if (argv[i] === '--file' && argv[i + 1]) out.file = argv[++i];
    else if ((argv[i] === '--microskillId' || argv[i] === '--microSkillId') && argv[i + 1]) {
      out.microskillId = argv[++i];
    }
  }
  return out;
}

async function main() {
  loadEnvLocal();
  const { file, microskillId } = parseArgs(process.argv);
  if (!file || !microskillId) {
    throw new Error('Usage: node scripts/import-questions-mongo.js --file <seed.json> --microskillId <id>');
  }
  const uri = String(process.env.MONGODB_URI || '').trim();
  if (!uri) throw new Error('MONGODB_URI missing in .env.local');

  const abs = path.resolve(process.cwd(), file);
  const raw = JSON.parse(fs.readFileSync(abs, 'utf8'));
  const rows = Array.isArray(raw) ? raw : [];
  if (rows.length === 0) throw new Error(`No question rows found in ${abs}`);

  await mongoose.connect(uri, { serverSelectionTimeoutMS: 10000 });
  const db = mongoose.connection.db;
  const coll = db.collection('questions');

  const nowIso = new Date().toISOString();
  const docs = rows.map((q, i) => ({
    ...q,
    id: String(q.id || `${microskillId}-${i + 1}`),
    microSkillId: microskillId,
    micro_skill_id: microskillId,
    microskill_id: microskillId,
    created_at: q.created_at || nowIso,
    updated_at: q.updated_at || nowIso,
  }));

  const result = await coll.insertMany(docs, { ordered: false });
  const total = await coll.countDocuments({ microSkillId: microskillId });

  console.log(
    JSON.stringify(
      {
        ok: true,
        inserted: Object.keys(result.insertedIds || {}).length,
        microskillId,
        totalQuestionsForMicroskill: total,
      },
      null,
      2
    )
  );
}

main()
  .catch((err) => {
    console.error(err.message || String(err));
    process.exit(1);
  })
  .finally(async () => {
    try {
      await mongoose.connection.close();
    } catch {}
  });
