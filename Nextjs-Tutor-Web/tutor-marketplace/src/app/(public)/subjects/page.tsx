import Link from "next/link";
import { BookOpen, ChevronRight, Calculator, Beaker, Languages, PenTool } from "lucide-react";
import { Header } from "@/components/layout/Header"
import { Footer } from "@/components/layout/Footer"

export default function SubjectsPage() {
    const categories = [
        {
            name: "Mathematics",
            icon: <Calculator className="w-6 h-6" />,
            color: "text-blue-600 bg-blue-50",
            subjects: ["Algebra", "Calculus", "Geometry", "Statistics", "Trigonometry", "Pre-Calculus", "Differential Equations"]
        },
        {
            name: "Science",
            icon: <Beaker className="w-6 h-6" />,
            color: "text-green-600 bg-green-50",
            subjects: ["Physics", "Chemistry", "Biology", "Environmental Science", "Computer Science", "Organic Chemistry"]
        },
        {
            name: "Languages",
            icon: <Languages className="w-6 h-6" />,
            color: "text-purple-600 bg-purple-50",
            subjects: ["English", "Spanish", "French", "Mandarin", "German", "Italian", "Japanese"]
        },
        {
            name: "Test Prep",
            icon: <PenTool className="w-6 h-6" />,
            color: "text-orange-600 bg-orange-50",
            subjects: ["SAT Math", "SAT Reading", "ACT", "GRE", "GMAT", "LSAT", "TOEFL"]
        }
    ];

    return (
        <>
            <Header />
            <div className="min-h-screen bg-gray-50">
                <div className="bg-white border-b py-16 text-center">
                    <h1 className="text-4xl font-bold text-gray-900 mb-4">Explore Subjects</h1>
                    <p className="text-xl text-gray-600 max-w-2xl mx-auto">Find expert tutors for any subject you need help with.</p>
                </div>

                <main className="container mx-auto px-4 py-16">
                    <div className="grid md:grid-cols-2 gap-8">
                        {categories.map((category) => (
                            <div key={category.name} className="bg-white rounded-xl shadow-sm border p-8 hover:shadow-md transition-shadow">
                                <div className="flex items-center gap-4 mb-6 border-b pb-4">
                                    <div className={`p-3 rounded-xl ${category.color}`}>
                                        {category.icon}
                                    </div>
                                    <h2 className="text-2xl font-bold text-gray-900">{category.name}</h2>
                                </div>

                                <div className="grid grid-cols-2 gap-y-3 gap-x-4">
                                    {category.subjects.map((subject) => (
                                        <Link
                                            key={subject}
                                            href={`/search?subject=${subject}`}
                                            className="group flex items-center justify-between p-2 rounded-lg hover:bg-gray-50 text-gray-700 transition-colors"
                                        >
                                            <span className="font-medium group-hover:text-[#00507d]">{subject}</span>
                                            <ChevronRight className="w-4 h-4 opacity-0 group-hover:opacity-100 text-[#00507d] transition-opacity" />
                                        </Link>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </main>
            </div>
            <Footer />
        </>
    )
}
