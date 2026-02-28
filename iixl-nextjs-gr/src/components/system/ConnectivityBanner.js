'use client';

import { useEffect, useState } from 'react';

import { clientError, clientLog } from '@/lib/debug/logger';

import styles from './ConnectivityBanner.module.css';

const POLL_MS = 10000;

export default function ConnectivityBanner() {
  const [status, setStatus] = useState({ degraded: false, retryAfterMs: 0, reason: 'none' });

  useEffect(() => {
    let mounted = true;
    let timer;

    const loadStatus = async () => {
      try {
        const response = await fetch('/api/system/status', { cache: 'no-store' });
        const data = await response.json();
        if (!mounted) return;
        setStatus({
          degraded: Boolean(data?.degraded),
          retryAfterMs: Number(data?.retryAfterMs || 0),
          reason: String(data?.reason || 'none'),
        });
        clientLog('system.connectivity', 'status refreshed', {
          degraded: Boolean(data?.degraded),
          reason: String(data?.reason || 'none'),
          retryAfterMs: Number(data?.retryAfterMs || 0),
        });
      } catch (error) {
        if (!mounted) return;
        clientError('system.connectivity', 'status fetch failed; marking degraded', error);
        setStatus({ degraded: true, retryAfterMs: 0, reason: 'status_api_unreachable' });
      } finally {
        if (mounted) {
          timer = setTimeout(loadStatus, POLL_MS);
        }
      }
    };

    loadStatus();

    return () => {
      mounted = false;
      if (timer) clearTimeout(timer);
    };
  }, []);

  if (!status.degraded) return null;

  const retrySeconds = status.retryAfterMs > 0 ? Math.ceil(status.retryAfterMs / 1000) : null;

  return (
    <div className={styles.banner} role="status" aria-live="polite">
      <span className={styles.dot} aria-hidden="true" />
      <span>
        Using offline fallback data.
        {retrySeconds ? ` Retrying Supabase in ~${retrySeconds}s.` : ' Supabase is currently unreachable.'}
      </span>
    </div>
  );
}
