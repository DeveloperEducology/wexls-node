import Link from "next/link";

export function Footer() {
    return (
        <footer className="w-full py-12 bg-[#0a1e29] text-gray-400">
            <div className="container mx-auto px-4 md:px-6 grid grid-cols-2 md:grid-cols-4 gap-8">
                <div className="space-y-4">
                    <h4 className="text-white font-bold text-lg">TutorSpace</h4>
                    <p className="text-sm">Connecting students with expert tutors worldwide. Get the grades you deserve.</p>
                </div>

                <div className="space-y-2">
                    <h4 className="text-white font-bold">Learn</h4>
                    <ul className="space-y-1 text-sm">
                        <li><Link href="/search" className="hover:text-white transition-colors">Find a Tutor</Link></li>
                        <li><Link href="/how-it-works" className="hover:text-white transition-colors">How it Works</Link></li>
                        <li><Link href="/subjects" className="hover:text-white transition-colors">By Subject</Link></li>
                    </ul>
                </div>

                <div className="space-y-2">
                    <h4 className="text-white font-bold">About</h4>
                    <ul className="space-y-1 text-sm">
                        <li><Link href="#" className="hover:text-white transition-colors">Our Story</Link></li>
                        <li><Link href="#" className="hover:text-white transition-colors">Careers</Link></li>
                        <li><Link href="#" className="hover:text-white transition-colors">Press</Link></li>
                    </ul>
                </div>

                <div className="space-y-2">
                    <h4 className="text-white font-bold">Support</h4>
                    <ul className="space-y-1 text-sm">
                        <li><Link href="#" className="hover:text-white transition-colors">Help Center</Link></li>
                        <li><Link href="#" className="hover:text-white transition-colors">Contact Us</Link></li>
                        <li><Link href="#" className="hover:text-white transition-colors">Trust & Safety</Link></li>
                    </ul>
                </div>
            </div>
            <div className="container mx-auto px-4 md:px-6 mt-12 pt-8 border-t border-gray-800 text-center text-xs">
                <p>© 2024 TutorSpace Inc. All rights reserved.</p>
            </div>
        </footer>
    )
}
