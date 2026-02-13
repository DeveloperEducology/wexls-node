
import { createClient } from "@/lib/supabase/client";
import { Database } from "@/lib/database.types";
import { Question, QuestionType } from "@/lib/types/question";

const supabase = createClient();

export async function getGrades() {
    const { data, error } = await supabase.from('grades').select('*').order('sort_order', { ascending: true });
    if (error) throw error;
    return data.map(grade => ({
        ...grade,
        level: grade.sort_order,
        color: grade.color_hex // Map for frontend
    }));
}

export async function getSubjects() {
    const { data, error } = await supabase.from('subjects').select('*');
    if (error) throw error;
    return data;
}

export async function getUnitsByGradeAndSubject(gradeId: string, subjectSlug: string) {
    // 1. Get Subject ID with case-insensitive search
    const { data: subject, error: subjectError } = await supabase
        .from('subjects')
        .select('id')
        .ilike('slug', subjectSlug)
        .maybeSingle();

    if (subjectError || !subject) {
        return [];
    }

    // 2. Resolve Grade ID if it's a slug
    let targetGradeId = gradeId;
    const isUuid = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(gradeId);

    if (!isUuid) {
        const { data: allGrades } = await supabase.from('grades').select('*');
        const match = allGrades?.find(g =>
            g.id === gradeId ||
            g.name.toLowerCase().replace(/\s+/g, '-') === gradeId.replace('grade-', '') ||
            `grade-${g.sort_order}` === gradeId
        );
        if (match) targetGradeId = match.id;
    }

    // 3. Fetch Units with Micro Skills
    const { data, error } = await supabase
        .from('units')
        .select(`
            *,
            micro_skills (
                id,
                name,
                code,
                sort_order,
                user_progress (
                    score,
                    questions_answered
                )
            )
        `)
        .eq('grade_id', targetGradeId)
        .eq('subject_id', subject.id)
        .order('code', { ascending: true });

    if (error) throw error;

    // 4. Transform and Sort
    return data.map(unit => {
        const sortedSkills = unit.micro_skills?.sort((a, b) => {
            // Prefer sort_order if available, else code
            const orderA = a.sort_order ?? 999;
            const orderB = b.sort_order ?? 999;
            if (orderA !== orderB) return orderA - orderB;
            return a.code.localeCompare(b.code, undefined, { numeric: true });
        });

        return {
            ...unit,
            title: `${unit.code ? unit.code + '. ' : ''}${unit.name}`,
            skills: sortedSkills,
        };
    }).sort((a, b) => a.code.localeCompare(b.code, undefined, { numeric: true }));
}

export async function getQuestionsBySkillId(skillId: string): Promise<Question[]> {
    // 1. Resolve Skill ID if it's not a UUID (e.g. "B.2")
    let targetSkillId = skillId;
    const isUuid = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(skillId);

    if (!isUuid) {
        // Find skill by code
        const { data: skillData } = await supabase
            .from('micro_skills') // Make sure table name matches DB types
            .select('id')
            .eq('code', skillId)
            .maybeSingle();

        if (skillData) {
            targetSkillId = skillData.id;
        } else {
            // Return empty if skill code cannot be resolved to a UUID
            return [];
        }
    }

    const { data, error } = await supabase
        .from('questions')
        .select('*')
        .eq('micro_skill_id', targetSkillId);

    if (error) throw error;

    // Transform DB question format to App Question format
    return data.map(q => {
        let qType = QuestionType.MCQ;
        if (q.type === 'imageChoice') qType = QuestionType.MCQ;
        if (q.type === 'drag_drop') qType = QuestionType.DragAndDrop;

        return {
            id: q.id,
            type: qType,
            difficulty: q.difficulty as 'easy' | 'medium' | 'hard',
            parts: q.parts as any,
            options: q.options as any,
            correctAnswerIndex: q.correct_answer_index,
            correctAnswerIndices: q.correct_answer_indices as any,
            correctAnswerText: q.correct_answer_text,
            solution: q.solution,
            dragGroups: q.drag_groups as any,
            dragItems: q.drag_items as any
        };
    });
}
