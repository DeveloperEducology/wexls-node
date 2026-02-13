
"use client";

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Calculator, Book, FlaskConical, Globe, BookOpen } from "lucide-react";
import Link from "next/link";
import { motion } from "framer-motion";

const grades = [
    "Pre-K", "Kindergarten", "First grade", "Second grade", "Third grade", "Fourth grade",
    "Fifth grade", "Sixth grade", "Seventh grade", "Eighth grade", "Ninth grade", "Tenth grade",
    "Eleventh grade", "Twelfth grade"
];

const subjects = [
    {
        title: "Math",
        description: "Numbers, geometry, algebra, calculus",
        icon: Calculator,
        color: "bg-blue-100 text-blue-600",
        id: "math"
    },
    {
        title: "Language Arts",
        description: "Reading, writing, vocabulary, grammar",
        icon: Book,
        color: "bg-purple-100 text-purple-600",
        id: "language-arts"
    },
    {
        title: "Science",
        description: "Biology, chemistry, physics, earth science",
        icon: FlaskConical,
        color: "bg-green-100 text-green-600",
        id: "science"
    },
    {
        title: "Social Studies",
        description: "History, geography, civics, economics",
        icon: Globe,
        color: "bg-orange-100 text-orange-600",
        id: "social-studies"
    }
];

export default function SubjectsPage() {
    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-5 duration-500">
            <div className="flex flex-col md:flex-row justify-between gap-4">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight text-slate-900">Learning</h2>
                    <p className="text-muted-foreground">Select a grade or subject to start practicing.</p>
                </div>
            </div>

            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
                {subjects.map((subject, index) => (
                    <motion.div
                        key={subject.title}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.1 }}
                    >
                        <Link href={`/subjects/grade-5/${subject.id}`} className="group block h-full">
                            <Card className="h-full hover:shadow-xl transition-all cursor-pointer border-slate-200 group-hover:border-green-200 hover:-translate-y-1 overflow-hidden relative">
                                <div className={`absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity`}>
                                    <subject.icon className="w-24 h-24" />
                                </div>
                                <CardHeader>
                                    <div className={`w-12 h-12 rounded-lg ${subject.color} flex items-center justify-center mb-4 transition-transform group-hover:scale-110 shadow-sm`}>
                                        <subject.icon className="h-6 w-6" />
                                    </div>
                                    <CardTitle className="text-lg group-hover:text-green-700 transition-colors text-slate-900">{subject.title}</CardTitle>
                                    <CardDescription className="text-slate-500">{subject.description}</CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <div className="flex items-center text-sm text-green-600 font-medium opacity-0 group-hover:opacity-100 transition-opacity -translate-x-2 group-hover:translate-x-0">
                                        Explore skills →
                                    </div>
                                </CardContent>
                            </Card>
                        </Link>
                    </motion.div>
                ))}
            </div>

            <div className="space-y-4">
                <h3 className="text-xl font-bold text-slate-900 flex items-center gap-2">
                    <BookOpen className="h-5 w-5 text-slate-500" />
                    Browse by Grade
                </h3>
                <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-3">
                    {grades.map((grade, i) => (
                        <Link key={grade} href={`/subjects/grade-${i}/${subjects[0].id}`}>
                            <Button variant="outline" className="w-full text-slate-600 hover:text-green-600 hover:border-green-200 hover:bg-green-50 transition-all">
                                {grade}
                            </Button>
                        </Link>
                    ))}
                </div>
            </div>
        </div>
    );
}
