
"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { ArrowRight, BookOpen, Brain, Trophy, Star, ChevronRight, Loader2 } from "lucide-react";
import { motion } from "framer-motion";
import { useEffect, useState } from "react";
import { getGrades } from "@/lib/supabase/fetchers";

// Fallback mock data
const MOCK_GRADES = [
  { id: "grade-pk", name: "Pre-K", level: -1 },
  { id: "grade-k", name: "Kindergarten", level: 0 },
  { id: "grade-1", name: "First grade", level: 1 },
  { id: "grade-2", name: "Second grade", level: 2 },
  { id: "grade-3", name: "Third grade", level: 3 },
  { id: "grade-4", name: "Fourth grade", level: 4 },
  { id: "grade-5", name: "Fifth grade", level: 5 },
  { id: "grade-6", name: "Sixth grade", level: 6 },
  { id: "grade-7", name: "Seventh grade", level: 7 },
  { id: "grade-8", name: "Eighth grade", level: 8 },
  { id: "grade-9", name: "Algebra 1", level: 9 },
  { id: "grade-10", name: "Geometry", level: 10 },
  { id: "grade-11", name: "Algebra 2", level: 11 },
  { id: "grade-12", name: "Calculus", level: 12 },
];

export default function Home() {
  const [grades, setGrades] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchGrades() {
      try {
        const data = await getGrades();
        if (data && data.length > 0) {
          setGrades(data);
        } else {
          // console.log("No grades found in DB, using mock");
          setGrades(MOCK_GRADES);
        }
      } catch (error) {
        // console.error("Error fetching grades:", error);
        setGrades(MOCK_GRADES);
      } finally {
        setLoading(false);
      }
    }
    fetchGrades();
  }, []);

  // Helper to assign colors based on index or level (IXL style)
  const getGradeColor = (index: number) => {
    const colors = [
      "bg-purple-100 text-purple-700 hover:bg-purple-200",
      "bg-pink-100 text-pink-700 hover:bg-pink-200",
      "bg-blue-100 text-blue-700 hover:bg-blue-200",
      "bg-green-100 text-green-700 hover:bg-green-200",
      "bg-yellow-100 text-yellow-700 hover:bg-yellow-200",
      "bg-orange-100 text-orange-700 hover:bg-orange-200",
      "bg-red-100 text-red-700 hover:bg-red-200",
      "bg-teal-100 text-teal-700 hover:bg-teal-200",
      "bg-indigo-100 text-indigo-700 hover:bg-indigo-200",
      "bg-cyan-100 text-cyan-700 hover:bg-cyan-200",
      "bg-slate-100 text-slate-700 hover:bg-slate-200",
    ];
    return colors[index % colors.length];
  };

  return (
    <div className="flex flex-col min-h-screen bg-slate-50 font-sans">
      {/* IXL-style Header/Nav */}
      <header className="bg-white border-b-4 border-[#00703c]">
        <div className="container mx-auto px-4 h-16 flex items-center justify-between">
          <div className="flex items-center gap-8 h-full">
            {/* Logo */}
            <Link href="/" className="flex items-center gap-1 group mr-4">
              <div className="bg-[#00703c] px-3 py-1 rounded-sm -skew-x-12 transform hover:scale-105 transition-transform shadow-sm">
                <span className="text-white font-black text-2xl tracking-tighter skew-x-12 inline-block">IXL</span>
              </div>
            </Link>

            {/* Main Nav Tabs */}
            <nav className="hidden md:flex items-center h-full gap-1 self-end">
              <Link href="#" className="h-full flex items-end pb-3 px-6 bg-[#00703c] text-white font-bold text-sm rounded-t-lg relative shadow-md">
                Learning
              </Link>
              <Link href="#" className="h-full flex items-end pb-3 px-6 bg-slate-100 hover:bg-slate-200 font-bold text-sm text-slate-600 border-t border-x border-slate-200 rounded-t-lg transition-colors">
                Assessment
              </Link>
              <Link href="#" className="h-full flex items-end pb-3 px-6 bg-slate-100 hover:bg-slate-200 font-bold text-sm text-slate-600 border-t border-x border-slate-200 rounded-t-lg transition-colors">
                Analytics
              </Link>
            </nav>
          </div>

          <div className="flex items-center gap-4 text-sm font-semibold text-slate-600">
            <span className="hidden sm:inline">Welcome, Student!</span>
          </div>
        </div>

        {/* Sub-nav (Subject tabs) */}
        <div className="bg-[#00703c] text-white shadow-lg relative z-10">
          <div className="container mx-auto px-4 flex items-center gap-0 overflow-x-auto no-scrollbar">
            <Link href="#" className="py-2.5 px-5 font-bold text-sm whitespace-nowrap bg-[#005a2b] relative after:content-[''] after:absolute after:bottom-0 after:left-1/2 after:-translate-x-1/2 after:border-b-[6px] after:border-x-[6px] after:border-b-white after:border-x-transparent">
              Math
            </Link>
            <Link href="#" className="py-2.5 px-5 font-medium hover:bg-[#005a2b] text-sm whitespace-nowrap transition-colors">
              Language arts
            </Link>
            <Link href="#" className="py-2.5 px-5 font-medium hover:bg-[#005a2b] text-sm whitespace-nowrap transition-colors">
              Science
            </Link>
            <Link href="#" className="py-2.5 px-5 font-medium hover:bg-[#005a2b] text-sm whitespace-nowrap transition-colors">
              Social studies
            </Link>
            <Link href="#" className="py-2.5 px-5 font-medium hover:bg-[#005a2b] text-sm whitespace-nowrap transition-colors">
              Spanish
            </Link>
          </div>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 bg-gradient-to-b from-[#eef7f2] to-white pb-20">
        <div className="container mx-auto px-4 py-8">

          {/* Dynamic Hero / Message */}
          <div className="bg-white p-8 rounded-xl shadow-sm border border-slate-200 mb-10 mt-4 text-center">
            <h1 className="text-3xl font-extrabold text-slate-800 tracking-tight mb-2">
              Recomendations
            </h1>
            <p className="text-slate-500 font-medium">
              Here are some skills picked just for you to practice based on your recent activity!
            </p>
            <div className="mt-6 flex flex-wrap justify-center gap-4">
              <Link href="/practice/A.1" className="bg-yellow-50 border border-yellow-200 hover:border-yellow-400 p-4 rounded-lg flex items-center gap-3 transition-all hover:shadow-md cursor-pointer group w-full md:w-auto md:min-w-[300px] text-left">
                <div className="bg-yellow-100 p-2 rounded-full text-yellow-600 group-hover:scale-110 transition-transform">
                  <Star className="w-5 h-5 fill-yellow-500" />
                </div>
                <div>
                  <div className="text-xs font-bold text-slate-400 uppercase tracking-widest">A.1 Counting</div>
                  <div className="font-bold text-slate-700">Skip-counting</div>
                </div>
              </Link>
              <Link href="/practice/B.2" className="bg-blue-50 border border-blue-200 hover:border-blue-400 p-4 rounded-lg flex items-center gap-3 transition-all hover:shadow-md cursor-pointer group w-full md:w-auto md:min-w-[300px] text-left">
                <div className="bg-blue-100 p-2 rounded-full text-blue-600 group-hover:scale-110 transition-transform">
                  <Trophy className="w-5 h-5" />
                </div>
                <div>
                  <div className="text-xs font-bold text-slate-400 uppercase tracking-widest">B.2 Ordering</div>
                  <div className="font-bold text-slate-700">Order numbers up to 100</div>
                </div>
              </Link>
            </div>
          </div>

          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-slate-800 flex items-center gap-2">
              <span className="w-1.5 h-6 bg-[#00703c] rounded-full inline-block"></span>
              Explore by Grade
            </h2>

            {loading ? (
              <div className="flex justify-center py-10">
                <Loader2 className="w-8 h-8 animate-spin text-green-600" />
              </div>
            ) : (
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-7 gap-3">
                {grades.map((grade, idx) => (
                  <Link key={grade.id} href={`/subjects/${grade.id}/math`} className="block group">
                    <div className={`h-28 rounded-lg ${getGradeColor(idx)} flex flex-col items-center justify-center p-4 transition-all duration-200 transform group-hover:-translate-y-1 group-hover:shadow-md border border-transparent group-hover:border-black/5 relative overflow-hidden`}>
                      <div className="absolute top-0 right-0 w-16 h-16 bg-white/20 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110"></div>
                      <span className="font-extrabold text-3xl mb-1 opacity-90">
                        {grade.name.includes("Pre-K") ? "PK" : grade.name.includes("Kindergarten") ? "K" : grade.level > 0 ? grade.level : isNaN(parseInt(grade.id)) ? grade.name.charAt(0) : grade.id}
                      </span>
                      <span className="font-bold text-xs uppercase tracking-wide opacity-75 text-center leading-tight">
                        {grade.name}
                      </span>
                    </div>
                  </Link>
                ))}
              </div>
            )}
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-slate-900 border-t py-12 text-slate-400 text-sm">
        <div className="container mx-auto px-4 grid md:grid-cols-4 gap-8 mb-8">
          <div>
            <h4 className="font-bold text-white mb-4">About IXL</h4>
            <ul className="space-y-2">
              <li>Privacy Policy</li>
              <li>Terms of Service</li>
              <li>Contact Us</li>
            </ul>
          </div>
          <div>
            <h4 className="font-bold text-white mb-4">Learning</h4>
            <ul className="space-y-2">
              <li>Math</li>
              <li>Language Arts</li>
              <li>Science</li>
            </ul>
          </div>
        </div>
        <div className="container mx-auto px-4 text-center border-t border-slate-800 pt-8">
          <p>&copy; 2024 IXL Learning Clone. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
