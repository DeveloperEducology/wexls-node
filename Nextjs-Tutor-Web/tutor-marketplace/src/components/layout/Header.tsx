import Link from "next/link";
import { Menu } from "lucide-react";

export function Header() {
    return (
        <header className="sticky top-0 z-50 w-full border-b bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/60">
            <div className="container mx-auto flex h-16 items-center px-4 md:px-6">
                <Link href="/" className="mr-6 flex items-center gap-2">
                    <span className="text-2xl font-bold text-[#00507d] tracking-tight">TutorSpace</span>
                </Link>
                <nav className="hidden md:flex items-center gap-6 text-sm font-medium text-gray-700">
                    <Link href="/search" className="hover:text-[#00507d] transition-colors">Find a Tutor</Link>
                    <Link href="/how-it-works" className="hover:text-[#00507d] transition-colors">How it Works</Link>
                    <Link href="/subjects" className="hover:text-[#00507d] transition-colors">Subjects</Link>
                    <Link href="/register?role=TUTOR" className="hover:text-[#00507d] transition-colors">Become a Tutor</Link>
                </nav>
                <div className="ml-auto flex items-center gap-4">
                    <Link href="/login" className="text-sm font-medium text-gray-700 hover:text-[#00507d] hidden sm:block">
                        Log In
                    </Link>
                    <Link href="/register" className="inline-flex h-9 items-center justify-center rounded-md bg-[#fb923c] hover:bg-[#f97316] px-6 text-sm font-bold text-white shadow transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-gray-950">
                        Get Started
                    </Link>
                    <button className="md:hidden">
                        <Menu className="h-6 w-6 text-gray-700" />
                    </button>
                </div>
            </div>
        </header>
    )
}
