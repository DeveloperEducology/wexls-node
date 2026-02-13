import { DashboardSidebar } from "@/components/layout/DashboardSidebar"
import { DollarSign, Users, Calendar, Clock, ArrowUpRight } from "lucide-react"

export default function TutorDashboard() {
    return (
        <div className="flex min-h-screen bg-gray-50">
            <DashboardSidebar role="TUTOR" />

            <main className="flex-1 p-8">
                <header className="flex justify-between items-center mb-8">
                    <div>
                        <h1 className="text-2xl font-bold text-gray-900">Welcome back, John!</h1>
                        <p className="text-gray-500">Here's what's happening today.</p>
                    </div>
                    <div className="flex items-center gap-4">
                        <span className="text-sm text-gray-500">Oct 24, 2024</span>
                        <div className="w-10 h-10 rounded-full bg-blue-100 border border-blue-200 flex items-center justify-center font-bold text-[#00507d]">JD</div>
                    </div>
                </header>

                {/* Stats Grid */}
                <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4 mb-8">
                    {[
                        { label: "Total Earnings", value: "$3,450", icon: DollarSign, trend: "+12%" },
                        { label: "Active Students", value: "24", icon: Users, trend: "+4%" },
                        { label: "Hours Taught", value: "156", icon: Clock, trend: "+8%" },
                        { label: "Upcoming Sessions", value: "3", icon: Calendar, trend: "Today" },
                    ].map((stat, i) => (
                        <div key={i} className="bg-white p-6 rounded-xl border shadow-sm">
                            <div className="flex justify-between items-start mb-4">
                                <div className="p-2 bg-blue-50 rounded-lg text-[#00507d]">
                                    <stat.icon className="w-5 h-5" />
                                </div>
                                <span className="text-green-600 text-xs font-bold flex items-center bg-green-50 px-2 py-1 rounded-full">
                                    {stat.trend} <ArrowUpRight className="w-3 h-3 ml-1" />
                                </span>
                            </div>
                            <h3 className="text-gray-500 text-sm font-medium">{stat.label}</h3>
                            <div className="text-2xl font-bold text-gray-900 mt-1">{stat.value}</div>
                        </div>
                    ))}
                </div>

                <div className="grid md:grid-cols-3 gap-8">
                    {/* Upcoming Sessions */}
                    <div className="md:col-span-2 bg-white rounded-xl border shadow-sm p-6">
                        <div className="flex justify-between items-center mb-6">
                            <h2 className="text-lg font-bold text-gray-900">Upcoming Sessions</h2>
                            <button className="text-sm text-[#00507d] font-medium hover:underline">View All</button>
                        </div>
                        <div className="space-y-4">
                            {[1, 2, 3].map((i) => (
                                <div key={i} className="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50 transition-colors">
                                    <div className="flex items-center gap-4">
                                        <div className="w-12 h-12 bg-gray-200 rounded-full flex-shrink-0"></div>
                                        <div>
                                            <div className="font-bold text-gray-900">Sarah Johnson</div>
                                            <div className="text-sm text-gray-500">Calculus II • 2:00 PM - 3:00 PM</div>
                                        </div>
                                    </div>
                                    <button className="bg-[#00507d] text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-[#003d5e]">
                                        Join Class
                                    </button>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Recent Activity / Requests */}
                    <div className="bg-white rounded-xl border shadow-sm p-6">
                        <h2 className="text-lg font-bold text-gray-900 mb-6">New Requests</h2>
                        <div className="space-y-6">
                            {[1, 2].map(i => (
                                <div key={i}>
                                    <div className="flex items-center gap-3 mb-3">
                                        <div className="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center text-orange-600 font-bold text-sm">JS</div>
                                        <div>
                                            <div className="font-bold text-sm">Jason S.</div>
                                            <div className="text-xs text-gray-500">Algebra I • $50/hr</div>
                                        </div>
                                    </div>
                                    <div className="flex gap-2">
                                        <button className="flex-1 bg-[#00507d] text-white py-2 rounded-md text-xs font-bold">Accept</button>
                                        <button className="flex-1 bg-gray-100 text-gray-700 py-2 rounded-md text-xs font-bold hover:bg-gray-200">Decline</button>
                                    </div>
                                </div>
                            ))}
                            {/* Placeholder for empty state */}
                            <div className="pt-4 border-t text-center text-sm text-gray-500">
                                No more pending requests
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    )
}
