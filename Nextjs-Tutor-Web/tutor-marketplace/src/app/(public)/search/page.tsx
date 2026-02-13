"use client"

import * as React from "react"
import { useSearchParams, useRouter } from "next/navigation"
import { Header } from "@/components/layout/Header"
import { Footer } from "@/components/layout/Footer"
import { Star, MapPin, SlidersHorizontal, ChevronDown } from "lucide-react"

export default function SearchPage() {
    const searchParams = useSearchParams()
    const router = useRouter()
    const subject = searchParams.get("subject")

    // Improved Mock Data
    const tutors = [
        {
            id: 1,
            name: "Jane Doe",
            subject: "Math",
            rate: 50,
            rating: 4.9,
            reviews: 120,
            location: "New York, NY",
            bio: "Certified Math teacher with 10+ years helping students ace SAT/ACTs.",
            tags: ["Algebra", "Calculus", "SAT Prep"],
            image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Jane"
        },
        {
            id: 2,
            name: "John Smith",
            subject: "Physics",
            rate: 60,
            rating: 5.0,
            reviews: 85,
            location: "London, UK",
            bio: "PhD in Physics. I make complex concepts simple and fun to understand.",
            tags: ["Physics 101", "Mechanics", "Thermodynamics"],
            image: "https://api.dicebear.com/7.x/avataaars/svg?seed=John"
        },
        {
            id: 3,
            name: "Alice Johnson",
            subject: "Chemistry",
            rate: 45,
            rating: 4.8,
            reviews: 200,
            location: "Online",
            bio: "Patient and encouraging tutor specializing in High School Chemistry.",
            tags: ["Organic Chemistry", "Biochem"],
            image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Alice"
        },
        {
            id: 4,
            name: "Robert Brown",
            subject: "Math",
            rate: 55,
            rating: 4.7,
            reviews: 45,
            location: "Online",
            bio: "Engineering student who loves teaching Math to younger students.",
            tags: ["Geometry", "Trigonometry"],
            image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Robert"
        },
    ]

    const filteredTutors = subject
        ? tutors.filter(t => t.subject.toLowerCase().includes(subject.toLowerCase()))
        : tutors

    return (
        <>
            <Header />
            <div className="flex flex-col min-h-screen bg-gray-50">

                {/* Search Header */}
                <div className="bg-[#00507d] py-8 px-4 text-white">
                    <div className="container mx-auto">
                        <h1 className="text-3xl font-bold mb-4">Find the perfect {subject || "tutor"} for you</h1>
                        <div className="flex gap-2 max-w-2xl bg-white p-2 rounded-lg">
                            <input
                                type="search"
                                placeholder="Search by subject (e.g. Math, Physics)..."
                                className="flex-1 px-4 py-2 text-gray-900 border-none outline-none"
                                defaultValue={subject || ""}
                                onChange={(e) => {
                                    // Debounce would go here
                                }}
                                onKeyDown={(e) => {
                                    if (e.key === 'Enter') router.push(`/search?subject=${e.currentTarget.value}`)
                                }}
                            />
                            <button className="bg-[#fb923c] hover:bg-[#f97316] text-white px-6 py-2 rounded-md font-bold transition-colors">
                                Search
                            </button>
                        </div>
                    </div>
                </div>

                <main className="flex-1 container mx-auto px-4 py-8">
                    <div className="flex flex-col md:flex-row gap-8">
                        {/* Filters Sidebar */}
                        <aside className="w-full md:w-64 space-y-6 shrink-0">
                            <div className="bg-white p-6 rounded-xl border shadow-sm">
                                <div className="flex items-center gap-2 font-bold text-gray-900 mb-4 border-b pb-2">
                                    <SlidersHorizontal className="w-4 h-4" /> Filters
                                </div>

                                <div className="space-y-6">
                                    <div>
                                        <h3 className="font-semibold text-sm mb-3">Price Per Hour</h3>
                                        <div className="space-y-2">
                                            <label className="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                                                <input type="checkbox" className="rounded border-gray-300 text-[#00507d] focus:ring-[#00507d]" /> $0 - $40
                                            </label>
                                            <label className="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                                                <input type="checkbox" className="rounded border-gray-300 text-[#00507d] focus:ring-[#00507d]" /> $40 - $70
                                            </label>
                                            <label className="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                                                <input type="checkbox" className="rounded border-gray-300 text-[#00507d] focus:ring-[#00507d]" /> $70+
                                            </label>
                                        </div>
                                    </div>

                                    <div>
                                        <h3 className="font-semibold text-sm mb-3">Availability</h3>
                                        <div className="flex flex-wrap gap-2">
                                            {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map(d => (
                                                <button key={d} className="px-2 py-1 text-xs border rounded hover:bg-gray-50">{d}</button>
                                            ))}
                                        </div>
                                    </div>

                                    <div>
                                        <h3 className="font-semibold text-sm mb-3">Rating</h3>
                                        <div className="space-y-2">
                                            <label className="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                                                <input type="radio" name="rating" className="text-[#00507d] focus:ring-[#00507d]" /> 4.5 & up
                                            </label>
                                            <label className="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                                                <input type="radio" name="rating" className="text-[#00507d] focus:ring-[#00507d]" /> 4.0 & up
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </aside>

                        {/* Results List */}
                        <div className="flex-1 space-y-4">
                            <div className="flex justify-between items-center mb-2">
                                <span className="text-gray-500 text-sm">Showing {filteredTutors.length} tutors</span>
                                <div className="flex items-center gap-2 text-sm text-gray-700">
                                    Sort by: <span className="font-semibold cursor-pointer flex items-center">Relevance <ChevronDown className="w-3 h-3 ml-1" /></span>
                                </div>
                            </div>

                            {filteredTutors.map((tutor) => (
                                <div key={tutor.id} className="bg-white p-6 rounded-xl border shadow-sm hover:shadow-md transition-all flex flex-col sm:flex-row gap-6">
                                    {/* Avatar */}
                                    <div className="shrink-0 flex flex-col items-center gap-2">
                                        <div className="w-24 h-24 rounded-full bg-gray-100 overflow-hidden border">
                                            <img src={tutor.image} alt={tutor.name} className="w-full h-full object-cover" />
                                        </div>
                                        <div className="text-center">
                                            <div className="font-bold text-lg">${tutor.rate}</div>
                                            <div className="text-xs text-gray-500">per hour</div>
                                        </div>
                                    </div>

                                    {/* Content */}
                                    <div className="flex-1 space-y-2">
                                        <div className="flex justify-between items-start">
                                            <div>
                                                <h3 className="text-xl font-bold text-gray-900 leading-tight">{tutor.name}</h3>
                                                <div className="text-[#00507d] font-medium">{tutor.subject} Tutor</div>
                                            </div>
                                            <div className="flex items-center gap-1 bg-yellow-50 px-2 py-1 rounded border border-yellow-100">
                                                <Star className="w-4 h-4 fill-current text-yellow-500" />
                                                <span className="font-bold text-sm">{tutor.rating}</span>
                                                <span className="text-xs text-gray-500">({tutor.reviews})</span>
                                            </div>
                                        </div>

                                        <div className="flex items-center gap-1 text-sm text-gray-500">
                                            <MapPin className="w-3 h-3" /> {tutor.location}
                                        </div>

                                        <p className="text-gray-600 text-sm line-clamp-2">
                                            {tutor.bio}
                                        </p>

                                        <div className="flex flex-wrap gap-2 pt-2">
                                            {tutor.tags.map(tag => (
                                                <span key={tag} className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full">
                                                    {tag}
                                                </span>
                                            ))}
                                        </div>
                                    </div>

                                    {/* Actions */}
                                    <div className="flex flex-col justify-center gap-2 sm:w-40 shrink-0 border-l sm:pl-6 border-gray-100">
                                        <a href={`/tutors/${tutor.name.toLowerCase().replace(' ', '-')}`} className="block w-full text-center bg-[#00507d] hover:bg-[#003d5e] text-white py-2 rounded-md font-medium text-sm transition-colors">
                                            View Profile
                                        </a>
                                        <button className="block w-full text-center border border-[#00507d] text-[#00507d] hover:bg-blue-50 py-2 rounded-md font-medium text-sm transition-colors">
                                            Message
                                        </button>
                                    </div>
                                </div>
                            ))}

                            {filteredTutors.length === 0 && (
                                <div className="text-center py-20 bg-white rounded-xl border">
                                    <p className="text-gray-500 text-lg">No tutors found matching your criteria.</p>
                                    <button
                                        onClick={() => router.push('/search')}
                                        className="mt-4 text-[#00507d] font-medium hover:underline"
                                    >
                                        Clear Filters
                                    </button>
                                </div>
                            )}
                        </div>
                    </div>
                </main>
            </div>
            <Footer />
        </>
    )
}
