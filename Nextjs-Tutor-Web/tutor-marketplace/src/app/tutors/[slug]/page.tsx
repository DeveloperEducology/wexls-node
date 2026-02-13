import { Header } from "@/components/layout/Header"
import { Footer } from "@/components/layout/Footer"
import { Star, MapPin, CheckCircle2, Calendar, Clock, Award, BookOpen } from "lucide-react"

export async function generateMetadata({ params }: { params: { slug: string } }) {
    // Mock fetch
    const name = params.slug.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
    return {
        title: `${name} - Tutor Profile | TutorSpace`,
        description: `Book a private math tutoring session with ${name}. 5 Star rated tutor.`,
    }
}

export default function TutorProfilePage({ params }: { params: { slug: string } }) {
    // Parsing the slug to make a mock name (e.g. "john-doe" -> "John Doe")
    const tutorName = params.slug.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ');

    return (
        <>
            <Header />
            <div className="min-h-screen bg-gray-50 py-8">
                <div className="container mx-auto px-4">

                    {/* Top Profile Card */}
                    <div className="bg-white rounded-2xl shadow-sm border overflow-hidden mb-8">
                        <div className="h-48 bg-[#00507d] relative">
                            {/* Cover Image pattern or solid color */}
                            <div className="absolute inset-0 opacity-20 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')]"></div>
                        </div>
                        <div className="px-8 pb-8">
                            <div className="flex flex-col md:flex-row gap-6 items-start -mt-16">
                                <div className="w-32 h-32 rounded-full border-4 border-white bg-white shadow-md overflow-hidden z-10">
                                    <img src={`https://api.dicebear.com/7.x/avataaars/svg?seed=${params.slug}`} alt={tutorName} className="w-full h-full object-cover" />
                                </div>
                                <div className="flex-1 pt-2 md:pt-16">
                                    <div className="flex flex-col md:flex-row justify-between items-start gap-4">
                                        <div>
                                            <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-2">
                                                {tutorName} <CheckCircle2 className="text-blue-500 fill-blue-50 w-6 h-6" />
                                            </h1>
                                            <p className="text-lg text-gray-600">Expert Mathematics Tutor specialized in Calculus & Algebra</p>
                                            <div className="flex items-center gap-4 mt-2 text-sm text-gray-500">
                                                <span className="flex items-center gap-1"><MapPin className="w-4 h-4" /> New York, NY (Online Available)</span>
                                                <span className="flex items-center gap-1"><Clock className="w-4 h-4" /> 500+ hours taught</span>
                                            </div>
                                        </div>
                                        <div className="text-right hidden md:block">
                                            <div className="text-2xl font-bold text-gray-900">$50<span className="text-sm font-normal text-gray-500">/hr</span></div>
                                            <div className="flex items-center gap-1 justify-end text-sm mt-1">
                                                <Star className="w-4 h-4 text-yellow-500 fill-current" />
                                                <span className="font-bold">4.9</span> (124 reviews)
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div className="mt-4 md:mt-16 w-full md:w-auto flex flex-col gap-2">
                                    <button className="bg-[#fb923c] hover:bg-[#f97316] text-white px-8 py-3 rounded-lg font-bold shadow-md transition-all">
                                        Book a Session
                                    </button>
                                    <button className="bg-white border hover:bg-gray-50 text-gray-700 px-8 py-2 rounded-lg font-medium transition-all">
                                        Message
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="grid md:grid-cols-3 gap-8">
                        {/* Left Column: Details */}
                        <div className="md:col-span-2 space-y-8">

                            {/* About Section */}
                            <div className="bg-white p-8 rounded-xl shadow-sm border">
                                <h2 className="text-xl font-bold mb-4">About Me</h2>
                                <p className="text-gray-600 leading-relaxed mb-4">
                                    Hello! I'm {tutorName}, a certified math educator with over 8 years of experience helping students unlock their full potential.
                                    My teaching philosophy focuses on building a strong conceptual foundation rather than rote memorization.
                                </p>
                                <p className="text-gray-600 leading-relaxed">
                                    I specialize in preparing high school students for SAT/ACT math sections and helping college students navigate the complexities of Calculus I, II, and III.
                                    Whether you're struggling to pass or aiming for an A+, I tailor my lessons to your unique learning style.
                                </p>
                            </div>

                            {/* Expertise */}
                            <div className="bg-white p-8 rounded-xl shadow-sm border">
                                <h2 className="text-xl font-bold mb-4">Subjects</h2>
                                <div className="flex flex-wrap gap-2">
                                    {["Algebra I & II", "Geometry", "Pre-Calculus", "AP Calculus AB/BC", "SAT Math", "Trigonometry"].map(sub => (
                                        <span key={sub} className="px-3 py-1 bg-blue-50 text-[#00507d] rounded-full text-sm font-medium">
                                            {sub}
                                        </span>
                                    ))}
                                </div>
                            </div>

                            {/* Education */}
                            <div className="bg-white p-8 rounded-xl shadow-sm border">
                                <h2 className="text-xl font-bold mb-4">Education & Certifications</h2>
                                <ul className="space-y-4">
                                    <li className="flex gap-4">
                                        <div className="bg-orange-100 p-2 rounded-lg h-fit"><Award className="w-6 h-6 text-orange-600" /></div>
                                        <div>
                                            <h3 className="font-bold text-gray-900">M.S. in Mathematics</h3>
                                            <p className="text-sm text-gray-500">Columbia University, 2018</p>
                                        </div>
                                    </li>
                                    <li className="flex gap-4">
                                        <div className="bg-blue-100 p-2 rounded-lg h-fit"><BookOpen className="w-6 h-6 text-blue-600" /></div>
                                        <div>
                                            <h3 className="font-bold text-gray-900">Certified Math Teacher (Grades 7-12)</h3>
                                            <p className="text-sm text-gray-500">New York State Education Department</p>
                                        </div>
                                    </li>
                                </ul>
                            </div>

                            {/* Reviews */}
                            <div className="bg-white p-8 rounded-xl shadow-sm border">
                                <h2 className="text-xl font-bold mb-6">Student Reviews</h2>
                                <div className="space-y-6">
                                    {[1, 2, 3].map((i) => (
                                        <div key={i} className="border-b pb-6 last:border-0 last:pb-0">
                                            <div className="flex justify-between items-start mb-2">
                                                <div className="flex items-center gap-2">
                                                    <div className="w-10 h-10 bg-gray-200 rounded-full"></div>
                                                    <div>
                                                        <div className="font-bold text-sm">Student {i}</div>
                                                        <div className="text-xs text-gray-500">2 weeks ago</div>
                                                    </div>
                                                </div>
                                                <div className="flex text-yellow-400">
                                                    {[1, 2, 3, 4, 5].map(star => <Star key={star} className="w-4 h-4 fill-current" />)}
                                                </div>
                                            </div>
                                            <p className="text-gray-600 text-sm">
                                                "Absolutely the best tutor I've ever had. Explained concepts in a way that finally made sense!"
                                            </p>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>

                        {/* Right Column: Sticky Booking Widget */}
                        <div className="md:col-span-1">
                            <div className="bg-white p-6 rounded-xl shadow-sm border sticky top-24">
                                <h3 className="font-bold text-lg mb-4">Schedule a Session</h3>

                                <div className="space-y-4">
                                    <div className="p-3 border rounded-lg hover:border-[#00507d] cursor-pointer transition-colors bg-gray-50">
                                        <div className="flex justify-between items-center mb-1">
                                            <span className="font-semibold text-sm">30 Minutes</span>
                                            <span className="font-bold">$30</span>
                                        </div>
                                        <p className="text-xs text-gray-500">Quick homework help</p>
                                    </div>
                                    <div className="p-3 border-2 border-[#00507d] bg-blue-50/50 rounded-lg cursor-pointer">
                                        <div className="flex justify-between items-center mb-1">
                                            <span className="font-semibold text-sm text-[#00507d]">60 Minutes</span>
                                            <span className="font-bold text-[#00507d]">$50</span>
                                        </div>
                                        <p className="text-xs text-gray-600">Standard lesson</p>
                                    </div>
                                </div>

                                <hr className="my-6" />

                                <div className="mb-4">
                                    <h4 className="font-semibold text-sm mb-2 flex items-center gap-2">
                                        <Calendar className="w-4 h-4" /> Availability
                                    </h4>
                                    {/* Mock Calendar Grid */}
                                    <div className="grid grid-cols-4 gap-2 text-center text-sm">
                                        {['Mon', 'Tue', 'Wed', 'Thu'].map(d => (
                                            <div key={d} className="p-2 bg-gray-100 rounded text-gray-600">{d}</div>
                                        ))}
                                    </div>
                                </div>

                                <button className="w-full bg-[#00507d] hover:bg-[#003d5e] text-white py-3 rounded-lg font-bold transition-all">
                                    Continue to Book
                                </button>
                                <p className="text-xs text-center text-gray-400 mt-4">Average response time: 1 hour</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <Footer />
        </>
    )
}
