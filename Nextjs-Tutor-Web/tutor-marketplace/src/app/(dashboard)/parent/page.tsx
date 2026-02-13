import { DashboardSidebar } from "@/components/layout/DashboardSidebar"
import { BookOpen, Calendar, Clock, Search } from "lucide-react"
import Link from "next/link"

export default function ParentDashboard() {
    return (
        <div className="flex min-h-screen bg-gray-50">
            <DashboardSidebar role="PARENT" />

            <main className="flex-1 p-8">
                <header className="flex justify-between items-center mb-8">
                    <div>
                        <h1 className="text-2xl font-bold text-gray-900">My Learning Dashboard</h1>
                        <p className="text-gray-500">Track your progress and upcoming classes.</p>
                    </div>
                    <div className="flex items-center gap-4">
                        <Link href="/search" className="bg-[#fb923c] hover:bg-[#f97316] text-white px-6 py-2 rounded-lg font-bold shadow-sm flex items-center gap-2">
                            <Search className="w-4 h-4" /> Find a Tutor
                        </Link>
                    </div>
                </header>

                <div className="grid md:grid-cols-3 gap-8">
                    {/* Main Content Area */}
                    <div className="md:col-span-2 space-y-8">

                        {/* Next Lesson Card */}
                        <div className="bg-gradient-to-r from-[#00507d] to-[#0070AA] rounded-2xl p-8 text-white shadow-lg relative overflow-hidden">
                            <div className="relative z-10">
                                <div className="text-blue-200 font-semibold mb-2 flex items-center gap-2">
                                    <Clock className="w-4 h-4" /> Starts in 2 hours
                                </div>
                                <h2 className="text-3xl font-bold mb-4">Physics: Mechanics Review</h2>
                                <div className="flex items-center gap-4 mb-8">
                                    <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center font-bold text-white">DR</div>
                                    <div>
                                        <div className="font-semibold">Dr. Robert</div>
                                        <div className="text-sm text-blue-100">Physics Tutor</div>
                                    </div>
                                </div>
                                <button className="bg-white text-[#00507d] px-6 py-3 rounded-lg font-bold hover:bg-gray-100 transition-colors">
                                    Prepare for Class
                                </button>
                            </div>
                            {/* Decor */}
                            <div className="absolute right-0 bottom-0 w-64 h-64 bg-white opacity-5 rounded-full -mb-20 -mr-20"></div>
                        </div>

                        {/* Recent Past Classes */}
                        <div className="bg-white rounded-xl border shadow-sm p-6">
                            <div className="flex justify-between items-center mb-6">
                                <h2 className="text-lg font-bold text-gray-900">Recent Classes</h2>
                                <button className="text-sm text-[#00507d] font-medium hover:underline">View History</button>
                            </div>
                            <div className="space-y-4">
                                {[
                                    { subject: "Algebra II", tutor: "Jane Doe", date: "Yesterday" },
                                    { subject: "Chemistry", tutor: "Mike Ross", date: "Oct 22" }
                                ].map((cls, i) => (
                                    <div key={i} className="flex items-center justify-between p-4 border rounded-lg">
                                        <div className="flex items-center gap-4">
                                            <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center">
                                                <BookOpen className="w-5 h-5 text-gray-500" />
                                            </div>
                                            <div>
                                                <div className="font-bold text-gray-900">{cls.subject}</div>
                                                <div className="text-sm text-gray-500">with {cls.tutor} • {cls.date}</div>
                                            </div>
                                        </div>
                                        <button className="text-[#00507d] text-sm font-semibold hover:underline">
                                            View Notes
                                        </button>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </div>

                    {/* Right Sidebar */}
                    <div className="space-y-6">
                        <div className="bg-white rounded-xl border shadow-sm p-6">
                            <h3 className="font-bold text-gray-900 mb-4 flex items-center gap-2">
                                <Calendar className="w-4 h-4" /> Your Schedule
                            </h3>
                            {/* Mini Calendar List */}
                            <div className="space-y-4">
                                {['Mon', 'Wed', 'Fri'].map(d => (
                                    <div key={d} className="flex gap-3 text-sm">
                                        <div className="font-bold text-gray-400 w-8">{d}</div>
                                        <div className="flex-1">
                                            <div className="bg-blue-50 p-2 rounded text-[#00507d] font-medium">
                                                4:00 PM - Math
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>

                        <div className="bg-[#fff4e5] rounded-xl border border-orange-100 p-6">
                            <h3 className="font-bold text-orange-800 mb-2">Need help with homework?</h3>
                            <p className="text-orange-700 text-sm mb-4">
                                Get instant help from expert tutors available now.
                            </p>
                            <Link href="/search" className="block w-full text-center bg-[#fb923c] text-white py-2 rounded-md font-bold text-sm hover:bg-[#f97316]">
                                Find Help
                            </Link>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    )
}
