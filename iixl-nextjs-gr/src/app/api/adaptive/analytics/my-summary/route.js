import { NextResponse } from 'next/server';
import { createServerClient } from '@/lib/supabase/server';

export async function POST(req) {
    const supabase = createServerClient();
    if (!supabase) {
        return NextResponse.json({ error: 'Supabase is not configured on server.' }, { status: 500 });
    }

    let payload;
    try {
        payload = await req.json();
    } catch {
        return NextResponse.json({ error: 'Invalid JSON body.' }, { status: 400 });
    }

    const { data: { user } } = await supabase.auth.getUser();

    // Secure the request: If a user is logged in, use their ID. Guest ID only as fallback for unauthenticated.
    const studentId = user?.id
        ? String(user.id)
        : (payload?.studentId ? String(payload.studentId).trim() : '');

    if (!studentId) {
        return NextResponse.json({ error: 'studentId is required or you must be logged in.' }, { status: 400 });
    }

    const [attemptsRes, logsRes, skillStateRes] = await Promise.all([
        supabase
            .from('attempt_events')
            .select('response_ms,micro_skill_id')
            .eq('student_id', studentId),
        supabase
            .from('student_question_log')
            .select('response_ms,microskill_id')
            .eq('student_id', studentId),
        supabase
            .from('student_skill_state')
            .select('status,micro_skill_id')
            .eq('student_id', studentId),
    ]);

    if (attemptsRes.error) {
        return NextResponse.json({ error: attemptsRes.error.message }, { status: 500 });
    }

    let totalMs = 0;
    const startedSkills = new Set();

    (attemptsRes.data || []).forEach(row => {
        totalMs += Number(row.response_ms || 0);
        startedSkills.add(String(row.micro_skill_id));
    });

    (logsRes.data || []).forEach(row => {
        totalMs += Number(row.response_ms || 0);
        startedSkills.add(String(row.microskill_id));
    });

    const masteredCount = (skillStateRes.data || []).filter(s => s.status === 'proficient' || s.status === 'mastered').length;

    return NextResponse.json({
        totalHours: Number((totalMs / 3600000).toFixed(2)),
        totalMinutes: Math.round(totalMs / 60000),
        skillsStarted: startedSkills.size,
        skillsMastered: masteredCount,
    });
}
