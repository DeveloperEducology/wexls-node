
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Progress } from "@/components/ui/progress"
import { Calculator, Book, FlaskConical, Globe, ArrowRight, Star, Clock } from "lucide-react"
import Link from "next/link"

const subjects = [
    {
        title: "Math",
        description: "Numbers, geometry, algebra, calculus",
        icon: Calculator,
        color: "bg-blue-100 text-blue-600",
        href: "/subjects/math"
    },
    {
        title: "Language Arts",
        description: "Reading, writing, vocabulary, grammar",
        icon: Book,
        color: "bg-purple-100 text-purple-600",
        href: "/subjects/language-arts"
    },
    {
        title: "Science",
        description: "Biology, chemistry, physics, earth science",
        icon: FlaskConical,
        color: "bg-green-100 text-green-600",
        href: "/subjects/science"
    },
    {
        title: "Social Studies",
        description: "History, geography, civics, economics",
        icon: Globe,
        color: "bg-orange-100 text-orange-600",
        href: "/subjects/social-studies"
    }
]

export default function DashboardPage() {
    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-5 duration-500">
            <div className="flex flex-col md:flex-row justify-between gap-4">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight text-slate-900">Dashboard</h2>
                    <p className="text-muted-foreground">Welcome back, Student! You're doing great.</p>
                </div>
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
                <Card className="col-span-4 bg-gradient-to-br from-green-600 to-green-700 text-white border-none shadow-lg">
                    <CardHeader>
                        <CardTitle>Keep up the momentum!</CardTitle>
                        <CardDescription className="text-green-100">
                            You practiced for 15 minutes today. Reach 20 minutes to hit your daily goal.
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-2">
                            <div className="flex justify-between text-sm font-medium">
                                <span>Progress</span>
                                <span>75%</span>
                            </div>
                            <Progress value={75} className="h-3 bg-green-800" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="col-span-3">
                    <CardHeader>
                        <CardTitle>Resume Learning</CardTitle>
                        <CardDescription>Pick up where you left off</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="flex items-center gap-4 p-4 rounded-lg bg-slate-50 border border-slate-100 hover:bg-slate-100 transition-colors cursor-pointer group">
                            <div className="bg-blue-100 p-2 rounded-full text-blue-600 group-hover:scale-110 transition-transform">
                                <Calculator className="h-6 w-6" />
                            </div>
                            <div className="flex-1">
                                <h4 className="font-semibold text-sm text-slate-900">Algebra I: Linear Equations</h4>
                                <div className="flex items-center gap-2 text-xs text-muted-foreground mt-1">
                                    <Clock className="h-3 w-3" /> 2 hours ago
                                    <span className="text-green-600 font-bold ml-2">SmartScore: 85</span>
                                </div>
                            </div>
                            <Button size="icon" variant="ghost" className="text-slate-400 group-hover:text-green-600">
                                <ArrowRight className="h-4 w-4" />
                            </Button>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
                {subjects.map((subject) => (
                    <Link key={subject.title} href={subject.href} className="group">
                        <Card className="h-full hover:shadow-lg transition-all cursor-pointer border-slate-200 group-hover:border-green-200 hover:-translate-y-1">
                            <CardHeader>
                                <div className={`w-12 h-12 rounded-lg ${subject.color} flex items-center justify-center mb-4 transition-transform group-hover:scale-110`}>
                                    <subject.icon className="h-6 w-6" />
                                </div>
                                <CardTitle className="text-lg group-hover:text-green-700 transition-colors text-slate-900">{subject.title}</CardTitle>
                                <CardDescription className="text-slate-500">{subject.description}</CardDescription>
                            </CardHeader>
                        </Card>
                    </Link>
                ))}
            </div>

            {/* Recent Activity / Recommendations */}
            <div className="grid gap-4 md:grid-cols-2">
                <Card>
                    <CardHeader>
                        <CardTitle>Recommended for you</CardTitle>
                        <CardDescription>Based on your recent activity</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        {[1, 2, 3].map((i) => (
                            <div key={i} className="flex items-start gap-4 p-3 rounded-lg hover:bg-slate-50 transition-colors cursor-pointer border border-transparent hover:border-slate-100">
                                <div className="bg-orange-100 p-2 rounded text-orange-600 mt-1">
                                    <Star className="h-4 w-4" />
                                </div>
                                <div>
                                    <h4 className="font-medium text-sm text-slate-900">Review: Multiplying Fractions</h4>
                                    <p className="text-xs text-muted-foreground">Math • Grade 5</p>
                                </div>
                            </div>
                        ))}
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader>
                        <CardTitle>Recent Awards</CardTitle>
                        <CardDescription>Your latest achievements</CardDescription>
                    </CardHeader>
                    <CardContent className="grid grid-cols-4 gap-2">
                        {[1, 2, 3, 4].map((i) => (
                            <div key={i} className="aspect-square bg-slate-50 rounded-lg flex items-center justify-center flex-col gap-1 p-2 text-center hover:bg-yellow-50 transition-colors cursor-pointer border border-slate-100 hover:border-yellow-200">
                                <div className="text-2xl animate-bounce" style={{ animationDuration: `${i + 1}s` }}>🏆</div>
                                <span className="text-[10px] font-medium leading-tight text-slate-600">Math Master</span>
                            </div>
                        ))}
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}
