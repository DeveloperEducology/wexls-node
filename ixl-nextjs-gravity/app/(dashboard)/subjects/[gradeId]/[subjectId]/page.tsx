"use client";

import Link from "next/link";
import React, { use, useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { ChevronRight, Star, Trophy, BookOpen, Loader2 } from "lucide-react";
import { getUnitsByGradeAndSubject } from "@/lib/supabase/fetchers";

// Mock data structure matching the user's description
const MOCK_UNITS = [
    {
        id: "unit-1",
        title: "A. Counting and Number Patterns",
        skills: [
            { id: "A.1", name: "Target A.1: Skip-counting", score: 85, practiced: true },
            { id: "A.2", name: "Target A.2: Skip-counting sequences", score: 0, practiced: false },
            { id: "A.3", name: "Target A.3: Counting patterns - up to 100", score: 0, practiced: false },
        ]
    },
    {
        id: "unit-2",
        title: "B. Comparing and Ordering",
        skills: [
            { id: "B.1", name: "Target B.1: Comparing numbers up to 100", score: 100, practiced: true },
            { id: "B.2", name: "Target B.2: Put numbers up to 100 in order", score: 45, practiced: true },
            { id: "B.3", name: "Target B.3: Greatest and least - word problems", score: 0, practiced: false },
        ]
    },
    {
        id: "unit-3",
        title: "C. Names of Numbers",
        skills: [
            { id: "C.1", name: "Target C.1: Ordinal numbers up to 10th", score: 0, practiced: false },
            { id: "C.2", name: "Target C.2: Ordinal numbers up to 100th", score: 0, practiced: false },
        ]
    }
];

export default function SubjectSkillsPage({ params }: { params: Promise<{ gradeId: string; subjectId: string }> }) {
    const { gradeId, subjectId } = use(params);
    const [units, setUnits] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function fetchUnits() {
            setLoading(true);
            try {
                // Extract clean subject slug if needed (e.g. "math" from "math")
                const subjectSlug = subjectId?.toLowerCase() || 'math';

                const data = await getUnitsByGradeAndSubject(gradeId, subjectSlug);

                if (data && data.length > 0) {
                    setUnits(data);
                } else {
                    setUnits(MOCK_UNITS);
                }
            } catch (err) {
                setUnits(MOCK_UNITS);
            } finally {
                setLoading(false);
            }
        }

        if (gradeId) fetchUnits();
    }, [gradeId, subjectId]);

    // Format gradeId and subjectId for display
    const formattedGrade = gradeId ? gradeId.replace("grade-", "Grade ") : "Grade";
    const formattedSubject = subjectId ? subjectId.replace("-", " ") : "Subject";

    // Determine color theme based on subject
    const themeColor = subjectId?.includes("math") ? "text-green-700 bg-green-50" : "text-blue-700 bg-blue-50";
    const headerColor = subjectId?.includes("math") ? "bg-[#00703c]" : "bg-blue-600";
    const borderColor = subjectId?.includes("math") ? "border-green-200" : "border-blue-200";

    return (
        <div className="min-h-screen bg-slate-50 font-sans">
            <header className={`${headerColor} text-white shadow-md sticky top-0 z-50`}>
                <div className="container mx-auto px-4 h-14 flex items-center justify-between">
                    <Link href="/" className="font-bold text-xl tracking-tight opacity-90 hover:opacity-100 transition-opacity flex items-center gap-2 group">
                        <div className="bg-white/20 p-1 rounded group-hover:bg-white/30 transition-colors">
                            <span className="font-black text-sm">IXL</span>
                        </div>
                        <div className="flex items-center gap-2 text-sm font-medium opacity-80">
                            <ChevronRight className="w-4 h-4" />
                            <span>{formattedGrade}</span>
                            <ChevronRight className="w-4 h-4" />
                            <span className="capitalize">{formattedSubject}</span>
                        </div>
                    </Link>

                    <div className="text-xs font-semibold bg-black/20 px-3 py-1 rounded-full">
                        {units.reduce((acc, unit) => acc + unit.skills.length, 0)} Skills Available
                    </div>
                </div>
            </header>

            <main className="container mx-auto px-4 py-8 max-w-5xl">
                <div className="bg-white rounded-xl shadow-lg border border-slate-200 overflow-hidden">
                    {/* Header Banner */}
                    <div className="p-8 border-b border-slate-100 bg-gradient-to-r from-slate-50 to-white relative overflow-hidden">
                        <div className="absolute top-0 right-0 w-32 h-32 bg-slate-100 rounded-bl-full -mr-16 -mt-16 opacity-50"></div>
                        <div className="relative z-10 flex items-center gap-6">
                            <div className={`p-4 rounded-2xl ${themeColor} shadow-inner`}>
                                <BookOpen className="w-10 h-10" />
                            </div>
                            <div>
                                <h1 className="text-3xl md:text-4xl font-extrabold text-slate-800 tracking-tight capitalize mb-2">
                                    {formattedGrade}: <span className={subjectId?.includes("math") ? "text-[#00703c]" : "text-blue-600"}>{formattedSubject}</span>
                                </h1>
                                <p className="text-slate-500 font-medium text-lg leading-relaxed max-w-2xl">
                                    Browse the list of skills below. Click any skill name to start practicing!
                                </p>
                            </div>
                        </div>
                    </div>

                    {/* Unit List */}
                    <div className="divide-y divide-slate-100">
                        {loading ? (
                            <div className="p-10 flex justify-center items-center">
                                <Loader2 className="h-8 w-8 animate-spin text-slate-400" />
                                <span className="ml-3 text-lg text-slate-500">Loading skills...</span>
                            </div>
                        ) : (
                            units.map((unit) => (
                                <div key={unit.id} className="p-6 md:p-10 hover:bg-slate-50/30 transition-colors">
                                    <h2 className="text-2xl font-bold text-slate-700 mb-8 flex items-center gap-4">
                                        <span className={`w-10 h-10 rounded-xl ${subjectId?.includes("math") ? "bg-green-100 text-green-700" : "bg-blue-100 text-blue-700"} flex items-center justify-center text-lg font-extrabold shadow-sm`}>
                                            {unit.title.split('.')[0]}
                                        </span>
                                        {unit.title.substring(unit.title.indexOf('.') + 1).trim()}
                                    </h2>

                                    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 ml-14">
                                        {unit.skills.map((skill: any) => (
                                            <Link
                                                key={skill.id}
                                                href={`/practice/${skill.id}`}
                                                className={`group relative flex flex-col justify-between p-5 rounded-xl bg-white border border-slate-200 shadow-sm hover:shadow-lg ${borderColor} hover:border-current transition-all cursor-pointer overflow-hidden transform hover:-translate-y-1`}
                                            >
                                                <div className={`absolute top-0 left-0 w-1.5 h-full bg-slate-200 group-hover:${subjectId?.includes("math") ? "bg-green-500" : "bg-blue-500"} transition-colors`}></div>

                                                <div className="flex justify-between items-start mb-3">
                                                    <span className="text-xs font-bold text-slate-400 uppercase tracking-widest group-hover:text-slate-600 transition-colors">
                                                        {skill.code || skill.id}
                                                    </span>
                                                    {skill.user_progress && skill.user_progress.length > 0 && (
                                                        <div className="flex items-center gap-1 text-[10px] font-bold bg-green-100 text-green-700 px-2 py-0.5 rounded-full ring-1 ring-green-600/20">
                                                            <Trophy className="w-3 h-3" />
                                                            {skill.user_progress[0].score || 0}
                                                        </div>
                                                    )}
                                                </div>

                                                <h3 className="font-semibold text-slate-700 group-hover:text-black text-sm leading-snug mb-4">
                                                    {skill.name.includes(':') ? skill.name.split(':')[1] : skill.name}
                                                </h3>

                                                <div className={`mt-auto opacity-0 group-hover:opacity-100 transition-all duration-300 translate-y-2 group-hover:translate-y-0 text-xs font-bold ${subjectId?.includes("math") ? "text-green-600" : "text-blue-600"} flex items-center gap-1 uppercase tracking-wider`}>
                                                    Start <ChevronRight className="w-3 h-3" />
                                                </div>
                                            </Link>
                                        ))}
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>
            </main>
        </div>
    );
}
