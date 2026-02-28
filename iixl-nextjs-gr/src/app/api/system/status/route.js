import { NextResponse } from 'next/server';
import mongoose from 'mongoose';

import { getCurriculumOutageStatus } from '@/lib/curriculum/server';

export async function GET() {
  const mongoUri = String(
    process.env.MONGODB_URI ||
    process.env.MONGO_URI ||
    process.env.NEXT_PUBLIC_MONGODB_URI ||
    ''
  ).trim();
  const hasMongoEnv = Boolean(mongoUri);
  let mongoReachable = false;
  let mongoError = '';

  if (hasMongoEnv) {
    try {
      if (mongoose.connection.readyState !== 1) {
        await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 4000, maxPoolSize: 5 });
      }
      await mongoose.connection.db.admin().ping();
      mongoReachable = true;
    } catch {
      mongoReachable = false;
      mongoError = 'ping_failed';
    }
  }

  const outage = getCurriculumOutageStatus();
  const degraded = !hasMongoEnv || !mongoReachable || outage.open;

  return NextResponse.json(
    {
      ok: true,
      degraded,
      mode: degraded ? 'fallback' : 'online',
      reason: !hasMongoEnv
        ? 'mongo_env_missing'
        : !mongoReachable
          ? 'mongo_unreachable'
        : outage.open
          ? 'mongo_network_unreachable'
          : 'none',
      retryAfterMs: outage.retryAfterMs,
      mongoError: degraded ? mongoError : '',
      checkedAt: new Date().toISOString(),
    },
    {
      headers: {
        'Cache-Control': 'no-store, max-age=0',
      },
    }
  );
}
