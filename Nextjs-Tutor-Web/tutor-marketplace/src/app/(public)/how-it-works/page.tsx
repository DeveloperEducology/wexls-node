import Link from "next/link";
import { CheckCircle, Search, Calendar, Video, ArrowRight, UserCheck } from "lucide-react";
import { Header } from "@/components/layout/Header"
import { Footer } from "@/components/layout/Footer"

export default function HowItWorksPage() {
    const steps = [
        {
            icon: <Search className="w-8 h-8 text-white" />,
            bg: "bg-blue-500",
            title: "1. Search for a Tutor",
            description: "Browse our extensive network of verified tutors. Filter by subject, price, and reviews to find your perfect match."
        },
        {
            icon: <UserCheck className="w-8 h-8 text-white" />,
            bg: "bg-indigo-500",
            title: "2. Compare & Select",
            description: "Read detailed profiles, watch intro videos, and see student reviews to ensure they fit your learning style."
        },
        {
            icon: <Calendar className="w-8 h-8 text-white" />,
            bg: "bg-purple-500",
            title: "3. Book a Session",
            description: "Choose a time that works for you. Our tutors offer flexible scheduling including nights and weekends."
        },
        {
            icon: <Video className="w-8 h-8 text-white" />,
            bg: "bg-orange-500",
            title: "4. Start Learning",
            description: "Connect via our secure video classroom with interactive whiteboard tools. Learning has never been easier."
        }
    ];

    return (
        <>
            <Header />
            <div className="min-h-screen bg-white">
                {/* Hero */}
                <div className="bg-[#0a1e29] text-white py-20 relative overflow-hidden">
                    <div className="container mx-auto px-4 text-center relative z-10">
                        <h1 className="text-4xl md:text-5xl font-bold mb-6">How TutorSpace Works</h1>
                        <p className="text-xl text-gray-300 max-w-2xl mx-auto">
                            We've made it simple to find expert help. Follow these 4 easy steps to boost your grades.
                        </p>
                    </div>
                    {/* Background Decor */}
                    <div className="absolute top-0 left-0 w-64 h-64 bg-blue-500 rounded-full mix-blend-multiply filter blur-3xl opacity-10 animate-blob"></div>
                    <div className="absolute top-0 right-0 w-64 h-64 bg-purple-500 rounded-full mix-blend-multiply filter blur-3xl opacity-10 animate-blob animation-delay-2000"></div>
                </div>

                <main className="container mx-auto px-4 py-20">
                    <div className="grid gap-12 max-w-5xl mx-auto">
                        {steps.map((step, index) => (
                            <div key={index} className="flex flex-col md:flex-row gap-8 items-center md:items-start group">
                                <div className={`shrink-0 w-20 h-20 rounded-2xl flex items-center justify-center shadow-lg transform group-hover:scale-110 transition-all ${step.bg}`}>
                                    {step.icon}
                                </div>
                                <div className="flex-1 text-center md:text-left">
                                    <h3 className="text-2xl font-bold mb-3 text-gray-900">{step.title}</h3>
                                    <p className="text-lg text-gray-600 leading-relaxed">{step.description}</p>
                                </div>
                                {index < steps.length - 1 && (
                                    <div className="hidden md:block self-center opacity-20">
                                        <ArrowRight className="w-8 h-8" />
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>

                    <div className="mt-24 text-center">
                        <div className="bg-gradient-to-r from-[#00507d] to-[#0070AA] rounded-3xl p-12 text-white shadow-xl relative overflow-hidden">
                            <div className="relative z-10">
                                <h2 className="text-3xl md:text-4xl font-bold mb-6">Ready to improve your grades?</h2>
                                <p className="text-lg text-blue-100 mb-8 max-w-2xl mx-auto">Join thousands of students who have already found their perfect mentor.</p>
                                <div className="flex flex-col sm:flex-row justify-center gap-4">
                                    <Link href="/search" className="bg-[#fb923c] hover:bg-[#f97316] text-white font-bold py-3 px-8 rounded-lg transition-colors shadow-md">
                                        Find a Tutor Now
                                    </Link>
                                    <Link href="/register?role=TUTOR" className="bg-white/10 hover:bg-white/20 border border-white/30 text-white font-bold py-3 px-8 rounded-lg transition-colors">
                                        Apply to Teach
                                    </Link>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
            <Footer />
        </>
    )
}
