'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';
import styles from './student-analytics.module.css';

function toPoints(values, width = 520, height = 140, pad = 16) {
    if (!Array.isArray(values) || values.length === 0) return '';
    const min = Math.min(...values);
    const max = Math.max(...values);
    const range = Math.max(1, max - min);
    return values.map((v, i) => {
        const x = pad + (i * ((width - pad * 2) / Math.max(1, values.length - 1)));
        const y = height - pad - (((v - min) / range) * (height - pad * 2));
        return `${x},${y}`;
    }).join(' ');
}

export default function StudentAnalyticsClient() {
    const supabase = createClient();
    const [studentId, setStudentId] = useState('');
    const [microSkillId, setMicroSkillId] = useState('');
    const [selectedMicroSkill, setSelectedMicroSkill] = useState('');
    const [dateFrom, setDateFrom] = useState('');
    const [dateTo, setDateTo] = useState('');
    const [phase, setPhase] = useState('');
    const [loading, setLoading] = useState(true);
    const [fetchLoading, setFetchLoading] = useState(false);
    const [error, setError] = useState('');
    const [data, setData] = useState(null);
    const [optionData, setOptionData] = useState({ microSkillOptions: [] });
    const [hasLoaded, setHasLoaded] = useState(false);
    const [userChecked, setUserChecked] = useState(false);

    useEffect(() => {
        async function loadUser() {
            const { data } = await supabase.auth.getUser();
            if (data?.user?.id) {
                setStudentId(data.user.id);
            } else {
                const localId = typeof window !== 'undefined' ? localStorage.getItem('wexls_student_id') : null;
                if (localId) setStudentId(localId);
                else setError('Please sign in or start practicing to view your analytics.');
            }
            setUserChecked(true);
            setLoading(false);
        }
        loadUser();
    }, [supabase.auth]);

    useEffect(() => {
        let active = true;
        const loadOptions = async () => {
            if (!studentId) return;
            try {
                const res = await fetch('/api/adaptive/analytics/my-options', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ studentId }),
                });
                const payload = await res.json();
                if (!res.ok || !active) return;
                setOptionData({
                    microSkillOptions: payload.microSkillOptions || [],
                });
                if (payload.microSkillOptions?.length > 0 && !selectedMicroSkill) {
                    const firstSkill = payload.microSkillOptions[0].id;
                    setSelectedMicroSkill(firstSkill);
                    setMicroSkillId(firstSkill);
                }
            } catch {
                if (!active) return;
            }
        };

        if (userChecked && studentId) {
            loadOptions();
        }
        return () => {
            active = false;
        };
    }, [studentId, userChecked, selectedMicroSkill]);

    const fetchData = async () => {
        if (!studentId || !microSkillId) {
            setError('studentId and microSkillId are required.');
            return;
        }
        setFetchLoading(true);
        setHasLoaded(true);
        setError('');
        try {
            const res = await fetch('/api/adaptive/analytics/score-breakdown', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    studentId,
                    microSkillId,
                    limit: 80,
                    dateFrom: dateFrom || undefined,
                    dateTo: dateTo || undefined,
                    phase: phase || undefined,
                }),
            });
            const raw = await res.text();
            let payload = {};
            try {
                payload = raw ? JSON.parse(raw) : {};
            } catch {
                payload = { error: raw || `Request failed with status ${res.status}` };
            }
            if (!res.ok) throw new Error(payload.error || 'Failed to load analytics.');
            setData(payload);
        } catch (err) {
            setData(null);
            setError(err?.message || 'Failed to load analytics.');
        } finally {
            setFetchLoading(false);
        }
    };

    useEffect(() => {
        if (studentId && microSkillId) {
            fetchData();
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [studentId, microSkillId]);

    if (loading) {
        return <div className={styles.page}><p>Loading your analytics...</p></div>;
    }

    const rows = data?.rows || [];
    const diagnostics = data?.diagnostics || null;
    const adaptiveSummary = data?.summary || null;
    const summary = useMemo(() => {
        if (!rows.length) return null;
        const correct = rows.filter((r) => r.isCorrect).length;
        const accuracy = Math.round((correct / rows.length) * 100);
        const avgDelta = Math.round(rows.reduce((acc, r) => acc + Number(r.estimatedDelta || 0), 0) / rows.length);
        const avgMs = Math.round(rows.reduce((acc, r) => acc + Number(r.factors?.responseMs || 0), 0) / rows.length);
        return { accuracy, avgDelta, avgMs, attempts: rows.length };
    }, [rows]);

    const accuracySeries = rows.map((r) => (r.isCorrect ? 100 : 0)).reverse();
    const deltaSeries = rows.map((r) => Number(r.estimatedDelta || 0)).reverse();
    const speedSeries = rows.map((r) => Number(r.factors?.responseMs || 0)).reverse();

    return (
        <div className={styles.page}>
            <div className={styles.header}>
                <h1>My Analytics</h1>
                <Link href="/" className={styles.homeLink}>Back Home</Link>
            </div>

            <div className={styles.controls}>
                <select
                    value={selectedMicroSkill}
                    onChange={(e) => {
                        setSelectedMicroSkill(e.target.value);
                        setMicroSkillId(e.target.value);
                    }}
                    aria-label="Micro skill picker"
                >
                    <option value="">Select a skill you practiced</option>
                    {optionData.microSkillOptions.map((item) => (
                        <option key={item.id} value={item.id}>
                            {(item.code ? `${item.code} - ` : '') + item.name} ({item.usageCount})
                        </option>
                    ))}
                </select>

                <input type="date" value={dateFrom} onChange={(e) => setDateFrom(e.target.value)} aria-label="From date" />
                <input type="date" value={dateTo} onChange={(e) => setDateTo(e.target.value)} aria-label="To date" />
                <select value={phase} onChange={(e) => setPhase(e.target.value)} aria-label="Phase filter">
                    <option value="">All phases</option>
                    <option value="warmup">warmup</option>
                    <option value="core">core</option>
                    <option value="challenge">challenge</option>
                    <option value="recovery">recovery</option>
                    <option value="done">done</option>
                </select>
                <button onClick={fetchData} disabled={fetchLoading || !microSkillId}>{fetchLoading ? 'Loading...' : 'Refresh'}</button>
            </div>

            {error && <p className={styles.error}>{error}</p>}

            {hasLoaded && !fetchLoading && !error && rows.length === 0 && (
                <div className={styles.emptyWrap}>
                    <p className={styles.emptyText}>
                        No practice history found for this skill in the selected date range.
                    </p>
                </div>
            )}

            {summary && (
                <>
                    <div className={styles.kpis}>
                        <div className={styles.kpi}><span>Attempts</span><strong>{summary.attempts}</strong></div>
                        <div className={styles.kpi}><span>Accuracy</span><strong>{summary.accuracy}%</strong></div>
                        <div className={styles.kpi}><span>Avg Delta</span><strong>{summary.avgDelta > 0 ? `+${summary.avgDelta}` : summary.avgDelta}</strong></div>
                        <div className={styles.kpi}><span>Avg Time</span><strong>{Math.round(summary.avgMs / 1000)} s</strong></div>
                    </div>

                    <div className={styles.charts}>
                        <div className={styles.chartCard} style={{ gridColumn: '1 / -1' }}>
                            <h3>Accuracy Trend</h3>
                            <svg viewBox="0 0 520 140" className={styles.chart}>
                                <polyline points={toPoints(accuracySeries)} fill="none" stroke="#22c55e" strokeWidth="3" />
                            </svg>
                        </div>
                        <div className={styles.chartCard}>
                            <h3>SmartScore Expected Delta</h3>
                            <svg viewBox="0 0 520 140" className={styles.chart}>
                                <polyline points={toPoints(deltaSeries)} fill="none" stroke="#0ea5e9" strokeWidth="3" />
                            </svg>
                        </div>
                        <div className={styles.chartCard}>
                            <h3>Response Time (ms) Trend</h3>
                            <svg viewBox="0 0 520 140" className={styles.chart}>
                                <polyline points={toPoints(speedSeries)} fill="none" stroke="#f97316" strokeWidth="3" />
                            </svg>
                        </div>
                    </div>

                    <div className={styles.tableWrap}>
                        <table className={styles.table}>
                            <thead>
                                <tr>
                                    <th>Time</th>
                                    <th>Adaptive</th>
                                    <th>Correct</th>
                                    <th>Expected Score Delta</th>
                                    <th>Difficulty</th>
                                    <th>Response Time</th>
                                </tr>
                            </thead>
                            <tbody>
                                {rows.map((row) => (
                                    <tr key={row.id}>
                                        <td>{new Date(row.createdAt).toLocaleTimeString()}</td>
                                        <td>{row.isAdaptive ? 'Yes' : 'No'}</td>
                                        <td>{row.isCorrect ? 'Yes' : 'No'}</td>
                                        <td>{row.estimatedDelta > 0 ? `+${row.estimatedDelta}` : row.estimatedDelta}</td>
                                        <td>{row.factors?.difficulty !== 'undefined' ? row.factors?.difficulty : '-'}</td>
                                        <td>{row.factors?.responseMs ? `${Math.round(row.factors.responseMs / 1000)}s` : '-'}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </>
            )}
        </div>
    );
}
