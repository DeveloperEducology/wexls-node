import { NextResponse } from 'next/server';
import { connectMongo } from '@/lib/db/mongo';
import mongoose from 'mongoose';

export const dynamic = 'force-dynamic';

export async function GET() {
    try {
        await connectMongo();
        const db = mongoose.connection.db;

        const filterCondition = { type: { $exists: false }, parts: { $exists: false } };
        const [grades, subjects, units, microskills, oldMicroskills] = await Promise.all([
            db.collection("grades").find(filterCondition).toArray(),
            db.collection("subjects").find(filterCondition).toArray(),
            db.collection("units").find(filterCondition).toArray(),
            db.collection("microskills").find(filterCondition).toArray(),
            db.collection("micro_skills").find(filterCondition).toArray(),
        ]);

        const normalizeId = (item) => {
            if (!item) return item;
            if (item._id && !item.id) item.id = String(item._id);
            return item;
        };

        const normGrades = grades.map(normalizeId);
        const normSubjects = subjects.map(normalizeId);
        const normUnits = units.map(normalizeId);

        const mergedMicroskills = [];
        const seenIds = new Set();

        for (const item of [...microskills, ...oldMicroskills]) {
            const norm = normalizeId(item);
            const strId = String(norm.id);
            if (!seenIds.has(strId)) {
                seenIds.add(strId);
                mergedMicroskills.push(norm);
            }
        }

        return NextResponse.json({
            grades: normGrades,
            subjects: normSubjects,
            units: normUnits,
            microskills: mergedMicroskills,
        });
    } catch (error) {
        console.error("Failed to fetch curriculum payload:", error);
        return NextResponse.json({ error: error?.message || "Internal server error" }, { status: 500 });
    }
}
