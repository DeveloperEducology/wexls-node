const DEFAULT_BACKEND_URL = 'http://localhost:4000';

function stripTrailingSlash(url) {
  return String(url || '').replace(/\/+$/, '');
}

export function backendUrl(path = '') {
  let base = stripTrailingSlash(process.env.NEXT_PUBLIC_BACKEND_URL || DEFAULT_BACKEND_URL);

  if (typeof window === 'undefined' && base.startsWith('/')) {
    const host = process.env.VERCEL_URL
      ? `https://${process.env.VERCEL_URL}`
      : `http://localhost:${process.env.PORT || 3000}`;
    base = `${host}${base}`;
  }

  const normalized = String(path || '').startsWith('/') ? String(path) : `/${String(path || '')}`;
  return `${base}${normalized}`;
}
