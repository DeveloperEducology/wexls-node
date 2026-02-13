"use client"
import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, Calendar, MessageSquare, DollarSign, Settings, BookOpen, LogOut } from "lucide-react";

export function DashboardSidebar({ role }: { role: "TUTOR" | "PARENT" }) {
    const pathname = usePathname();

    const tutorLinks = [
        { href: "/dashboard/tutor", label: "Overview", icon: LayoutDashboard },
        { href: "/dashboard/tutor/sessions", label: "My Sessions", icon: Calendar },
        { href: "/dashboard/tutor/messages", label: "Messages", icon: MessageSquare },
        { href: "/dashboard/tutor/earnings", label: "Earnings", icon: DollarSign },
        { href: "/dashboard/tutor/profile", label: "My Profile", icon: Settings },
    ];

    const parentLinks = [
        { href: "/dashboard/parent", label: "Overview", icon: LayoutDashboard },
        { href: "/search", label: "Find a Tutor", icon: BookOpen },
        { href: "/dashboard/parent/sessions", label: "My Classes", icon: Calendar },
        { href: "/dashboard/parent/messages", label: "Messages", icon: MessageSquare },
        { href: "/dashboard/parent/settings", label: "Settings", icon: Settings },
    ];

    const links = role === "TUTOR" ? tutorLinks : parentLinks;

    return (
        <aside className="w-64 bg-white border-r h-screen hidden md:flex flex-col sticky top-0">
            <div className="p-6 border-b">
                <Link href="/" className="flex items-center gap-2">
                    <span className="text-xl font-bold text-[#00507d] tracking-tight">TutorSpace</span>
                </Link>
                <div className="mt-1 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                    {role === "TUTOR" ? "Tutor Portal" : "Student Portal"}
                </div>
            </div>

            <nav className="flex-1 p-4 space-y-1">
                {links.map((link) => {
                    const Icon = link.icon;
                    const isActive = pathname === link.href;
                    return (
                        <Link
                            key={link.href}
                            href={link.href}
                            className={`flex items-center gap-3 px-3 py-2 text-sm font-medium rounded-md transition-colors ${isActive
                                    ? "bg-blue-50 text-[#00507d]"
                                    : "text-gray-700 hover:bg-gray-50 hover:text-gray-900"
                                }`}
                        >
                            <Icon className={`w-5 h-5 ${isActive ? "text-[#00507d]" : "text-gray-400"}`} />
                            {link.label}
                        </Link>
                    )
                })}
            </nav>

            <div className="p-4 border-t">
                <button className="flex items-center gap-3 px-3 py-2 w-full text-sm font-medium text-gray-700 rounded-md hover:bg-red-50 hover:text-red-700 transition-colors">
                    <LogOut className="w-5 h-5 text-gray-400" />
                    Sign Out
                </button>
            </div>
        </aside>
    )
}
