'use client';

import { useEffect } from 'react';
import Link from 'next/link';

export default function Error({ error, reset }) {
    useEffect(() => {
        console.error('App Error:', error);
    }, [error]);

    return (
        <div style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: '60vh',
            textAlign: 'center',
            padding: '2rem'
        }}>
            <h1 style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>Oops! Something went wrong</h1>
            <p style={{ color: '#666', marginBottom: '2rem', maxWidth: '500px' }}>
                We encountered an unexpected error. Don't worry, your progress is safe.
            </p>
            <div style={{ display: 'flex', gap: '1rem' }}>
                <button
                    onClick={() => reset()}
                    style={{
                        padding: '0.75rem 1.5rem',
                        backgroundColor: '#007bff',
                        color: 'white',
                        border: 'none',
                        borderRadius: '8px',
                        cursor: 'pointer',
                        fontWeight: '600'
                    }}
                >
                    Try again
                </button>
                <Link
                    href="/"
                    style={{
                        padding: '0.75rem 1.5rem',
                        backgroundColor: '#f8f9fa',
                        color: '#333',
                        textDecoration: 'none',
                        borderRadius: '8px',
                        border: '1px solid #ddd',
                        fontWeight: '600'
                    }}
                >
                    Go Home
                </Link>
            </div>
        </div>
    );
}
