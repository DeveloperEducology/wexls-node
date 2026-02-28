const isDev = process.env.NODE_ENV !== 'production';
const serverEnabled = process.env.DEBUG_WEXLS_LOGS === '1' || isDev;
const browserEnabled =
  (typeof process !== 'undefined' && process.env.NEXT_PUBLIC_DEBUG_WEXLS_LOGS === '1') ||
  isDev;

function stamp() {
  return new Date().toISOString();
}

function safeMeta(meta) {
  if (!meta) return undefined;
  try {
    return JSON.parse(JSON.stringify(meta));
  } catch {
    return { note: 'meta_not_serializable' };
  }
}

export function serverLog(scope, message, meta = undefined) {
  if (!serverEnabled) return;
  const data = safeMeta(meta);
  if (data !== undefined) {
    console.log(`[WEXLS][${scope}][${stamp()}] ${message}`, data);
  } else {
    console.log(`[WEXLS][${scope}][${stamp()}] ${message}`);
  }
}

export function serverError(scope, message, error, meta = undefined) {
  if (!serverEnabled) return;
  const errorMeta = {
    ...(safeMeta(meta) || {}),
    error: error?.message || String(error || 'unknown_error'),
    stack: error?.stack || undefined,
  };
  console.error(`[WEXLS][${scope}][${stamp()}] ${message}`, errorMeta);
}

export async function serverTimed(scope, label, fn, meta = undefined) {
  const start = Date.now();
  try {
    const result = await fn();
    serverLog(scope, `${label} success`, {
      ...(safeMeta(meta) || {}),
      durationMs: Date.now() - start,
    });
    return result;
  } catch (error) {
    serverError(scope, `${label} failed`, error, {
      ...(safeMeta(meta) || {}),
      durationMs: Date.now() - start,
    });
    throw error;
  }
}

export function clientLog(scope, message, meta = undefined) {
  if (typeof window === 'undefined' || !browserEnabled) return;
  const data = safeMeta(meta);
  if (data !== undefined) {
    console.log(`[WEXLS][${scope}][${stamp()}] ${message}`, data);
  } else {
    console.log(`[WEXLS][${scope}][${stamp()}] ${message}`);
  }
}

export function clientError(scope, message, error, meta = undefined) {
  if (typeof window === 'undefined' || !browserEnabled) return;
  const errorMeta = {
    ...(safeMeta(meta) || {}),
    error: error?.message || String(error || 'unknown_error'),
    stack: error?.stack || undefined,
  };
  console.error(`[WEXLS][${scope}][${stamp()}] ${message}`, errorMeta);
}

export async function clientTimed(scope, label, fn, meta = undefined) {
  const start = (typeof performance !== 'undefined' ? performance.now() : Date.now());
  try {
    const result = await fn();
    const end = (typeof performance !== 'undefined' ? performance.now() : Date.now());
    clientLog(scope, `${label} success`, {
      ...(safeMeta(meta) || {}),
      durationMs: Math.round(end - start),
    });
    return result;
  } catch (error) {
    const end = (typeof performance !== 'undefined' ? performance.now() : Date.now());
    clientError(scope, `${label} failed`, error, {
      ...(safeMeta(meta) || {}),
      durationMs: Math.round(end - start),
    });
    throw error;
  }
}

