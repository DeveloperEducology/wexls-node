import { NextResponse } from 'next/server';
import { createServerClient } from '@/lib/supabase/server';

const MICROSKILL_TABLES = ['micro_skills', 'microskills'];
const ORDER_COLUMNS = ['sort_order', 'idx', 'created_at', 'id'];

async function fetchMicroskills(supabase) {
    for (const table of MICROSKILL_TABLES) {
        for (const orderColumn of ORDER_COLUMNS) {
            const { data, error } = await supabase
                .from(table)
                .select('id,code,name,slug')
                .order(orderColumn, { ascending: true })
                .limit(500);
            if (!error) return data || [];
        }
        const fallback = await supabase.from(table).select('id,code,name,slug').limit(500);
        if (!fallback.error) return fallback.data || [];
    }
    return [];
}

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

    // Secure the request: prioritize authenticated user ID. Guest ID is only for unauthenticated users.
    const studentId = user?.id
        ? String(user.id)
        : (payload?.studentId ? String(payload.studentId).trim() : '');

    if (!studentId) {
        return NextResponse.json({ error: 'studentId is required or you must be logged in.' }, { status: 400 });
    }

    const [attemptsRes, logsRes, microskills] = await Promise.all([
        supabase
            .from('attempt_events')
            .select('micro_skill_id,created_at')
            .eq('student_id', studentId)
            .order('created_at', { ascending: false })
            .limit(1000),
        supabase
            .from('student_question_log')
            .select('microskill_id,created_at')
            .eq('student_id', studentId)
            .order('created_at', { ascending: false })
            .limit(1000),
        fetchMicroskills(supabase),
    ]);

    if (attemptsRes.error) {
        return NextResponse.json({ error: attemptsRes.error.message || 'Failed to load options from attempts.' }, { status: 500 });
    }

    const skillUseMap = new Map();
    for (const row of (attemptsRes.data || [])) {
        const microSkillId = String(row.micro_skill_id || '').trim();
        if (microSkillId) {
            skillUseMap.set(microSkillId, (skillUseMap.get(microSkillId) || 0) + 1);
        }
    }

    for (const row of (logsRes.data || [])) {
        const microSkillId = String(row.microskill_id || '').trim();
        if (microSkillId) {
            skillUseMap.set(microSkillId, (skillUseMap.get(microSkillId) || 0) + 1);
        }
    }

    const microskillOptions = microskills
        .map((skill) => ({
            id: String(skill.id),
            code: skill.code || '',
            name: skill.name || '',
            slug: skill.slug || '',
            usageCount: skillUseMap.get(String(skill.id)) || 0,
        }))
        .filter(skill => skill.usageCount > 0);

    return NextResponse.json({
        microSkillOptions: microskillOptions.sort((a, b) => b.usageCount - a.usageCount),
    });
}
