import mongoose from 'mongoose';
import fs from 'fs';
import path from 'path';

let mongoConnectPromise = null;

function getMongoUri() {
  const raw = (
    process.env.MONGODB_URI ||
    process.env.MONGO_URI ||
    process.env.NEXT_PUBLIC_MONGODB_URI ||
    ''
  );
  const fromEnv = String(raw).trim().replace(/^['"]|['"]$/g, '');
  if (fromEnv) return fromEnv;

  // Fallback for dev/runtime setups where process.env is not hydrated as expected.
  try {
    const envPath = path.join(process.cwd(), '.env.local');
    if (!fs.existsSync(envPath)) return '';
    const content = fs.readFileSync(envPath, 'utf8');
    const line = content
      .split('\n')
      .map((l) => l.trim())
      .find((l) => l.startsWith('MONGODB_URI='));
    if (!line) return '';
    return line.slice('MONGODB_URI='.length).trim().replace(/^['"]|['"]$/g, '');
  } catch {
    return '';
  }
}

async function connectMongo() {
  if (mongoose.connection.readyState === 1) return mongoose.connection;
  const uri = getMongoUri();
  if (!uri) return null;

  if (!mongoConnectPromise) {
    mongoConnectPromise = mongoose.connect(uri, {
      serverSelectionTimeoutMS: 10000,
      maxPoolSize: 10,
    });
  }

  await mongoConnectPromise;
  return mongoose.connection;
}

function normalizeDoc(doc) {
  if (!doc) return doc;
  const out = { ...doc };
  if (out._id != null && out.id == null) out.id = String(out._id);
  delete out._id;
  return out;
}

function parseSelect(selectClause) {
  const raw = String(selectClause || '*').trim();
  if (!raw || raw === '*') return null;
  const fields = raw.split(',').map((f) => f.trim()).filter(Boolean);
  if (fields.length === 0) return null;
  const projection = {};
  for (const field of fields) projection[field] = 1;
  return projection;
}

function mergeFilter(base, next) {
  if (!next || typeof next !== 'object') return base;
  const out = { ...(base || {}) };
  for (const [key, value] of Object.entries(next)) {
    if (key === '$or') {
      out.$or = [...(out.$or || []), ...value];
      continue;
    }
    if (value && typeof value === 'object' && !Array.isArray(value)) {
      out[key] = { ...(out[key] || {}), ...value };
    } else {
      out[key] = value;
    }
  }
  return out;
}

function idCondition(value) {
  const clauses = [{ id: value }];
  if (mongoose.Types.ObjectId.isValid(String(value))) {
    clauses.push({ _id: new mongoose.Types.ObjectId(String(value)) });
  } else {
    clauses.push({ _id: String(value) });
  }
  return { $or: clauses };
}

class MongoQuery {
  constructor(db, table) {
    this.db = db;
    this.table = table;
    this._select = '*';
    this._filter = {};
    this._sort = [];
    this._limit = null;
    this._op = 'select';
    this._payload = null;
    this._upsertOptions = {};
    this._wantSingle = false;
    this._wantMaybeSingle = false;
  }

  select(clause = '*') {
    this._select = clause;
    return this;
  }

  eq(column, value) {
    const condition = column === 'id' ? idCondition(value) : { [column]: value };
    this._filter = mergeFilter(this._filter, condition);
    return this;
  }

  gte(column, value) {
    this._filter = mergeFilter(this._filter, { [column]: { $gte: value } });
    return this;
  }

  lte(column, value) {
    this._filter = mergeFilter(this._filter, { [column]: { $lte: value } });
    return this;
  }

  order(column, { ascending = true } = {}) {
    const key = column === 'id' ? '_id' : column;
    this._sort.push([key, ascending ? 1 : -1]);
    return this;
  }

  limit(value) {
    const parsed = Number(value);
    if (Number.isFinite(parsed) && parsed > 0) this._limit = Math.floor(parsed);
    return this;
  }

  insert(payload) {
    this._op = 'insert';
    this._payload = payload;
    return this;
  }

  update(payload) {
    this._op = 'update';
    this._payload = payload;
    return this;
  }

  delete() {
    this._op = 'delete';
    this._payload = null;
    return this;
  }

  upsert(payload, options = {}) {
    this._op = 'upsert';
    this._payload = payload;
    this._upsertOptions = options || {};
    return this;
  }

  single() {
    this._wantSingle = true;
    return this;
  }

  maybeSingle() {
    this._wantMaybeSingle = true;
    return this;
  }

  async _runSelect() {
    const projection = parseSelect(this._select);
    let cursor = this.db.collection(this.table).find(this._filter, projection ? { projection } : {});
    if (this._sort.length > 0) cursor = cursor.sort(this._sort);
    if (this._limit) cursor = cursor.limit(this._limit);
    const rows = (await cursor.toArray()).map(normalizeDoc);
    return { data: rows, error: null };
  }

  async _runInsert() {
    const docs = Array.isArray(this._payload) ? this._payload : [this._payload];
    const nowIso = new Date().toISOString();
    const insertDocs = docs.map((doc) => ({
      ...(doc || {}),
      created_at: doc?.created_at ?? nowIso,
      updated_at: doc?.updated_at ?? nowIso,
    }));
    const result = await this.db.collection(this.table).insertMany(insertDocs);
    const ids = Object.values(result.insertedIds);
    const rows = await this.db.collection(this.table).find({ _id: { $in: ids } }).toArray();
    return { data: rows.map(normalizeDoc), error: null };
  }

  async _runUpdate() {
    const patch = {
      ...(this._payload || {}),
      updated_at: (this._payload || {}).updated_at ?? new Date().toISOString(),
    };
    await this.db.collection(this.table).updateMany(this._filter, { $set: patch });
    const projection = parseSelect(this._select);
    const rows = await this.db.collection(this.table).find(
      this._filter,
      projection ? { projection } : {}
    ).toArray();
    return { data: rows.map(normalizeDoc), error: null };
  }

  async _runDelete() {
    await this.db.collection(this.table).deleteMany(this._filter);
    return { data: null, error: null };
  }

  async _runUpsert() {
    const payload = this._payload || {};
    const onConflict = String(this._upsertOptions.onConflict || '').trim();
    let filter = {};

    if (onConflict) {
      const cols = onConflict.split(',').map((s) => s.trim()).filter(Boolean);
      for (const col of cols) {
        if (payload[col] !== undefined) filter[col] = payload[col];
      }
    }

    if (Object.keys(filter).length === 0 && payload.id != null) {
      filter = mongoose.Types.ObjectId.isValid(String(payload.id))
        ? { _id: new mongoose.Types.ObjectId(String(payload.id)) }
        : { id: payload.id };
    }

    if (Object.keys(filter).length === 0) {
      return this._runInsert();
    }

    const nowIso = new Date().toISOString();
    const result = await this.db.collection(this.table).findOneAndUpdate(
      filter,
      {
        $set: { ...payload, updated_at: payload.updated_at ?? nowIso },
        $setOnInsert: { created_at: payload.created_at ?? nowIso },
      },
      { upsert: true, returnDocument: 'after' }
    );
    const updatedDoc = result && typeof result === 'object' && 'value' in result ? result.value : result;
    return { data: updatedDoc ? [normalizeDoc(updatedDoc)] : [], error: null };
  }

  async execute() {
    try {
      await connectMongo();
      if (!this.db) this.db = mongoose.connection?.db;
      if (!this.db) return { data: null, error: { message: 'MongoDB not configured.' } };

      let result;
      if (this._op === 'select') result = await this._runSelect();
      else if (this._op === 'insert') result = await this._runInsert();
      else if (this._op === 'update') result = await this._runUpdate();
      else if (this._op === 'delete') result = await this._runDelete();
      else if (this._op === 'upsert') result = await this._runUpsert();
      else result = { data: null, error: { message: `Unsupported op: ${this._op}` } };

      if (result.error) return result;

      if (this._wantSingle) {
        if (!Array.isArray(result.data) || result.data.length === 0) {
          return { data: null, error: { message: 'No rows returned for single().' } };
        }
        return { data: result.data[0], error: null };
      }
      if (this._wantMaybeSingle) {
        return { data: Array.isArray(result.data) && result.data.length > 0 ? result.data[0] : null, error: null };
      }
      return result;
    } catch (error) {
      return { data: null, error: { message: error?.message || String(error) } };
    }
  }

  then(resolve, reject) {
    return this.execute().then(resolve, reject);
  }
}

export function createServerClient() {
  const uri = getMongoUri();
  if (!uri) return null;

  const connection = mongoose.connection;
  const db = connection?.db;

  return {
    from(table) {
      return new MongoQuery(db, table);
    },
    async rpc(_name, _params) {
      return { data: null, error: { message: 'RPC not implemented in Mongo mode.' } };
    },
  };
}
