
"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import {
    LayoutDashboard,
    BookOpen,
    Trophy,
    BarChart,
    Settings,
    HelpCircle,
    LogOut,
} from "lucide-react";

const sidebarItems = [
    {
        title: "Dashboard",
        href: "/dashboard",
        icon: LayoutDashboard,
    },
    {
        title: "Learning",
        href: "/subjects", // or /learning
        icon: BookOpen,
    },
    {
        title: "Analytics",
        href: "/analytics",
        icon: BarChart,
    },
    {
        title: "Awards",
        href: "/awards",
        icon: Trophy,
    },
    {
        title: "Settings",
        href: "/profile",
        icon: Settings,
    },
];

export function Sidebar({ className }: { className?: string }) {
    const pathname = usePathname();

    return (
        <div className={cn("pb-12 h-full", className)}>
            <div className="space-y-4 py-4 h-full flex flex-col">
                <div className="px-6 py-2">
                    <Link href="/dashboard" className="flex items-center gap-2">
                        <div className="w-8 h-8 bg-green-500 rounded flex items-center justify-center text-white font-bold text-xl">
                            IXL
                        </div>
                        <span className="text-xl font-bold tracking-tight text-white">
                            Learning
                        </span>
                    </Link>
                </div>
                <div className="px-3 py-2 flex-1">
                    <div className="space-y-1">
                        {sidebarItems.map((item) => (
                            <Link
                                key={item.href}
                                href={item.href}
                                className={cn(
                                    "group flex items-center rounded-md px-3 py-2.5 text-sm font-medium hover:bg-slate-800 hover:text-white transition-colors",
                                    pathname.startsWith(item.href) || (item.href === "/dashboard" && pathname === "/dashboard")
                                        ? "bg-green-600 text-white shadow-md"
                                        : "text-slate-400"
                                )}
                            >
                                <item.icon className="mr-2 h-4 w-4" />
                                <span>{item.title}</span>
                            </Link>
                        ))}
                    </div>
                </div>
                <div className="px-3 py-2">
                    <Link
                        href="/help"
                        className="group flex items-center rounded-md px-3 py-2 text-sm font-medium text-slate-400 hover:bg-slate-800 hover:text-white transition-colors"
                    >
                        <HelpCircle className="mr-2 h-4 w-4" />
                        <span>Help Center</span>
                    </Link>
                    <button
                        className="w-full group flex items-center rounded-md px-3 py-2 text-sm font-medium text-slate-400 hover:bg-slate-800 hover:text-white transition-colors text-left"
                    >
                        <LogOut className="mr-2 h-4 w-4" />
                        <span>Sign out</span>
                    </button>
                </div>
            </div>
        </div>
    );
}
