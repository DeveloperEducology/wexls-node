const USER_KEY = 'wexls_local_user';
const listeners = new Set();

function readUser() {
  if (typeof window === 'undefined') return null;
  try {
    const raw = window.localStorage.getItem(USER_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function writeUser(user) {
  if (typeof window === 'undefined') return;
  if (!user) window.localStorage.removeItem(USER_KEY);
  else window.localStorage.setItem(USER_KEY, JSON.stringify(user));
}

function emitAuth(event, user) {
  const session = user ? { user } : null;
  for (const listener of listeners) {
    try {
      listener(event, session);
    } catch {}
  }
}

function buildUser(email) {
  const normalizedEmail = String(email || '').trim().toLowerCase();
  const safeEmail = normalizedEmail || 'learner@example.com';
  const baseId = (typeof crypto !== 'undefined' && crypto.randomUUID)
    ? crypto.randomUUID()
    : `user_${Date.now()}`;
  return {
    id: baseId,
    email: safeEmail,
    user_metadata: {
      name: safeEmail.split('@')[0],
    },
  };
}

export function createClient() {
  return {
    auth: {
      async signInWithPassword({ email }) {
        const user = buildUser(email);
        writeUser(user);
        emitAuth('SIGNED_IN', user);
        return { data: { user, session: { user } }, error: null };
      },
      async signUp({ email }) {
        const user = buildUser(email);
        writeUser(user);
        emitAuth('SIGNED_IN', user);
        return { data: { user, session: { user } }, error: null };
      },
      async getUser() {
        const user = readUser();
        return { data: { user }, error: null };
      },
      onAuthStateChange(callback) {
        listeners.add(callback);
        return {
          data: {
            subscription: {
              unsubscribe() {
                listeners.delete(callback);
              },
            },
          },
        };
      },
      async signOut() {
        writeUser(null);
        emitAuth('SIGNED_OUT', null);
        return { error: null };
      },
    },
  };
}
