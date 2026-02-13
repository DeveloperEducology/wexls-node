import Link from "next/link";
import { CheckCircle2, ChevronRight, Star, Menu } from "lucide-react";

export default function Home() {
  return (
    <div className="flex flex-col min-h-screen bg-white">
      {/* Header */}
      <header className="sticky top-0 z-50 w-full border-b bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/60">
        <div className="container flex h-16 items-center px-4 md:px-6">
          <Link href="/" className="mr-6 flex items-center gap-2">
            <span className="text-2xl font-bold text-gray-900 tracking-tight">TutorSpace</span>
          </Link>
          <nav className="hidden md:flex items-center gap-6 text-sm font-medium text-gray-700">
            <Link href="/search" className="hover:text-black transition-colors">Find a Tutor</Link>
            <Link href="/how-it-works" className="hover:text-black transition-colors">How it Works</Link>
            <Link href="/subjects" className="hover:text-black transition-colors">Subjects</Link>
            <Link href="/register?role=TUTOR" className="hover:text-black transition-colors">Become a Tutor</Link>
          </nav>
          <div className="ml-auto flex items-center gap-4">
            <Link href="/login" className="text-sm font-medium text-gray-700 hover:text-black hidden sm:block">
              Log In
            </Link>
            <Link href="/register" className="inline-flex h-9 items-center justify-center rounded-md bg-[#00507d] px-6 text-sm font-medium text-white shadow transition-colors hover:bg-[#003d5e] focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-gray-950">
              Get Started
            </Link>
            <button className="md:hidden">
              <Menu className="h-6 w-6" />
            </button>
          </div>
        </div>
      </header>

      <main className="flex-1">
        {/* Hero Section */}
        <section className="relative w-full py-20 md:py-32 bg-[#00507d] text-white overflow-hidden">
          {/* Decorative circles */}
          <div className="absolute top-0 right-0 -mr-20 -mt-20 w-96 h-96 rounded-full bg-[#006ba6] opacity-20 blur-3xl"></div>
          <div className="absolute bottom-0 left-0 -ml-20 -mb-20 w-72 h-72 rounded-full bg-[#003d5e] opacity-20 blur-3xl"></div>

          <div className="container relative px-4 md:px-6 flex flex-col items-center text-center space-y-8">
            <h1 className="text-4xl md:text-6xl font-extrabold tracking-tight max-w-4xl">
              Get the grades you want. <br className="hidden md:block" />
              <span className="text-[#a6d8ff]">Learn from the best.</span>
            </h1>
            <p className="max-w-[700px] text-lg text-gray-100 md:text-xl">
              Connect with expert tutors in Math, Science, English, and 30+ other subjects.
              Available 24/7 for 1-on-1 personalized learning.
            </p>

            {/* Search Bar Component inside Hero */}
            <div className="w-full max-w-2xl mt-8 bg-white p-2 rounded-lg shadow-xl flex flex-col md:flex-row gap-2">
              <input
                type="text"
                placeholder="What subject do you need help with?"
                className="flex-1 px-4 py-3 rounded-md text-gray-900 border-none outline-none focus:ring-0"
              />
              <Link href="/search" className="bg-[#fb923c] hover:bg-[#f97316] text-white font-bold py-3 px-8 rounded-md transition-colors flex items-center justify-center">
                Find a Tutor
              </Link>
            </div>

            <div className="pt-4 flex items-center gap-2 text-sm text-gray-200">
              <Star className="h-4 w-4 text-yellow-400 fill-current" />
              <span className="font-semibold">4.8/5</span> average rating from 10,000+ students
            </div>
          </div>
        </section>

        {/* Feature/Trust Section */}
        <section className="w-full py-16 bg-gray-50">
          <div className="container px-4 md:px-6">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold tracking-tighter sm:text-4xl text-gray-900">Why Students Love TutorSpace</h2>
              <p className="mt-4 text-gray-500">We provide the best tools and tutors to help you succeed.</p>
            </div>

            <div className="grid gap-8 md:grid-cols-3">
              {[
                { title: "Expert Tutors", desc: "Our tutors are rigorously vetted and subject matter experts.", icon: "🎓" },
                { title: "Personalized Learning", desc: "1-on-1 sessions tailored to your unique learning style.", icon: "✨" },
                { title: "Better Grades", desc: "95% of our students report improved grades and confidence.", icon: "📈" }
              ].map((feature, i) => (
                <div key={i} className="flex flex-col items-center text-center p-6 bg-white rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                  <span className="text-4xl mb-4">{feature.icon}</span>
                  <h3 className="text-xl font-bold mb-2">{feature.title}</h3>
                  <p className="text-gray-500">{feature.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Subjects Grid */}
        <section className="w-full py-16 bg-white">
          <div className="container px-4 md:px-6">
            <div className="flex justify-between items-end mb-8">
              <h2 className="text-3xl font-bold tracking-tighter text-gray-900">Popular Subjects</h2>
              <Link href="/subjects" className="text-[#00507d] font-semibold hover:underline flex items-center">
                View All Subjects <ChevronRight className="h-4 w-4" />
              </Link>
            </div>

            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {["Algebra", "Calculus", "Chemistry", "Physics", "English", "Computer Science", "Biology", "History"].map((subject) => (
                <Link key={subject} href={`/search?subject=${subject}`} className="block group">
                  <div className="p-4 border rounded-lg hover:border-[#00507d] hover:bg-[#f0f9ff] transition-all cursor-pointer text-center">
                    <span className="font-medium text-gray-700 group-hover:text-[#00507d]">{subject}</span>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="w-full py-20 bg-[#00507d] text-white">
          <div className="container px-4 md:px-6 grid md:grid-cols-2 gap-12 items-center">
            <div className="space-y-6">
              <h2 className="text-3xl md:text-4xl font-bold">Ready to improve your grades?</h2>
              <p className="text-lg text-gray-200">
                Join thousands of students who are mastering their subjects with TutorSpace.
                Get matched with a perfect tutor in under 60 seconds.
              </p>
              <div className="flex gap-4">
                <Link href="/register?role=PARENT" className="bg-[#fb923c] hover:bg-[#f97316] text-white font-bold py-3 px-6 rounded-md transition-colors">
                  Find a Tutor
                </Link>
                <Link href="/register?role=TUTOR" className="bg-transparent border border-white hover:bg-white/10 text-white font-bold py-3 px-6 rounded-md transition-colors">
                  Become a Tutor
                </Link>
              </div>
            </div>
            <div className="hidden md:block">
              <div className="bg-white/10 p-8 rounded-2xl backdrop-blur-sm border border-white/20">
                <div className="flex gap-4 items-start mb-6">
                  <div className="h-12 w-12 rounded-full bg-gray-300 flex-shrink-0"></div>
                  <div>
                    <div className="font-bold">Sarah J.</div>
                    <div className="text-sm text-gray-300">Parent of 10th Grader</div>
                  </div>
                  <div className="ml-auto flex text-yellow-400">
                    {[1, 2, 3, 4, 5].map(i => <Star key={i} className="h-4 w-4 fill-current" />)}
                  </div>
                </div>
                <p className="italic">
                  "My son was struggling with Calculus, but after just 3 sessions on TutorSpace, he aced his midterm! The tutor was incredibly patient and knowledgeable."
                </p>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="w-full py-12 bg-gray-900 text-gray-400">
        <div className="container px-4 md:px-6 grid grid-cols-2 md:grid-cols-4 gap-8">
          <div className="space-y-4">
            <h4 className="text-white font-bold text-lg">TutorSpace</h4>
            <p className="text-sm">Connecting students with expert tutors worldwide.</p>
          </div>

          <div className="space-y-2">
            <h4 className="text-white font-bold">Learn</h4>
            <ul className="space-y-1 text-sm">
              <li><Link href="#" className="hover:text-white">Find a Tutor</Link></li>
              <li><Link href="#" className="hover:text-white">How it Works</Link></li>
              <li><Link href="#" className="hover:text-white">Online Tutoring</Link></li>
            </ul>
          </div>

          <div className="space-y-2">
            <h4 className="text-white font-bold">About</h4>
            <ul className="space-y-1 text-sm">
              <li><Link href="#" className="hover:text-white">Our Story</Link></li>
              <li><Link href="#" className="hover:text-white">Careers</Link></li>
              <li><Link href="#" className="hover:text-white">Press</Link></li>
            </ul>
          </div>

          <div className="space-y-2">
            <h4 className="text-white font-bold">Support</h4>
            <ul className="space-y-1 text-sm">
              <li><Link href="#" className="hover:text-white">Help Center</Link></li>
              <li><Link href="#" className="hover:text-white">Contact Us</Link></li>
              <li><Link href="#" className="hover:text-white">Trust & Safety</Link></li>
            </ul>
          </div>
        </div>
        <div className="container px-4 md:px-6 mt-12 pt-8 border-t border-gray-800 text-center text-xs">
          <p>© 2024 TutorSpace Inc. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
