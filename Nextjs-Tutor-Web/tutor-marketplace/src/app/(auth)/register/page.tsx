"use client"

import * as React from "react"
import { useSearchParams, useRouter } from "next/navigation"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import * as z from "zod"
import { Loader2, ArrowLeft, GraduationCap, User } from "lucide-react"
import Link from "next/link"

const formSchema = z.object({
    name: z.string().min(2, "Name is required"),
    email: z.string().email(),
    password: z.string().min(8, "Password must be at least 8 characters"),
    role: z.enum(["PARENT", "TUTOR"]),
})

export default function RegisterPage() {
    const searchParams = useSearchParams()
    const router = useRouter()
    const roleParam = searchParams.get("role")
    const [isLoading, setIsLoading] = React.useState<boolean>(false)

    const form = useForm<z.infer<typeof formSchema>>({
        resolver: zodResolver(formSchema),
        defaultValues: {
            name: "",
            email: "",
            password: "",
            role: (roleParam === "TUTOR" || roleParam === "PARENT") ? roleParam : "PARENT",
        },
    })

    async function onSubmit(values: z.infer<typeof formSchema>) {
        setIsLoading(true)
        // Simulate API call
        console.log(values)

        setTimeout(() => {
            setIsLoading(false)
            if (values.role === "TUTOR") {
                router.push("/onboarding")
            } else {
                router.push("/dashboard/parent")
            }
        }, 1000)

    }

    const currentRole = form.watch("role");

    return (
        <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
            <div className="sm:mx-auto sm:w-full sm:max-w-md">
                <Link href="/" className="flex justify-center mb-6">
                    <span className="text-3xl font-bold text-[#00507d] tracking-tight">TutorSpace</span>
                </Link>
                <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
                    Create your account
                </h2>
                <p className="mt-2 text-center text-sm text-gray-600">
                    Already have an account?{' '}
                    <Link href="/login" className="font-medium text-[#00507d] hover:text-[#003d5e]">
                        Sign in
                    </Link>
                </p>
            </div>

            <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
                <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10 border border-gray-100">

                    {/* Role Toggle */}
                    <div className="flex p-1 bg-gray-100 rounded-lg mb-8">
                        <button
                            type="button"
                            onClick={() => form.setValue("role", "PARENT")}
                            className={`flex-1 flex items-center justify-center gap-2 py-2 text-sm font-medium rounded-md transition-all ${currentRole === "PARENT" ? "bg-white text-gray-900 shadow-sm" : "text-gray-500 hover:text-gray-900"
                                }`}
                        >
                            <User className="w-4 h-4" /> Parent / Student
                        </button>
                        <button
                            type="button"
                            onClick={() => form.setValue("role", "TUTOR")}
                            className={`flex-1 flex items-center justify-center gap-2 py-2 text-sm font-medium rounded-md transition-all ${currentRole === "TUTOR" ? "bg-white text-[#00507d] shadow-sm" : "text-gray-500 hover:text-gray-900"
                                }`}
                        >
                            <GraduationCap className="w-4 h-4" /> Tutor
                        </button>
                    </div>

                    <form className="space-y-6" onSubmit={form.handleSubmit(onSubmit)}>

                        <div>
                            <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                                Full Name
                            </label>
                            <div className="mt-1">
                                <input
                                    id="name"
                                    type="text"
                                    disabled={isLoading}
                                    className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-[#00507d] focus:border-[#00507d] sm:text-sm"
                                    {...form.register("name")}
                                />
                                {form.formState.errors.name && (
                                    <p className="text-xs text-red-600 mt-1">
                                        {form.formState.errors.name.message}
                                    </p>
                                )}
                            </div>
                        </div>

                        <div>
                            <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                                Email address
                            </label>
                            <div className="mt-1">
                                <input
                                    id="email"
                                    type="email"
                                    autoComplete="email"
                                    disabled={isLoading}
                                    className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-[#00507d] focus:border-[#00507d] sm:text-sm"
                                    {...form.register("email")}
                                />
                                {form.formState.errors.email && (
                                    <p className="text-xs text-red-600 mt-1">
                                        {form.formState.errors.email.message}
                                    </p>
                                )}
                            </div>
                        </div>

                        <div>
                            <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                                Password
                            </label>
                            <div className="mt-1">
                                <input
                                    id="password"
                                    type="password"
                                    autoComplete="new-password"
                                    disabled={isLoading}
                                    className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-[#00507d] focus:border-[#00507d] sm:text-sm"
                                    {...form.register("password")}
                                />
                                {form.formState.errors.password && (
                                    <p className="text-xs text-red-600 mt-1">
                                        {form.formState.errors.password.message}
                                    </p>
                                )}
                            </div>
                        </div>

                        <div>
                            <button
                                type="submit"
                                disabled={isLoading}
                                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-[#00507d] hover:bg-[#003d5e] focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[#00507d] disabled:opacity-50 disabled:cursor-not-allowed"
                            >
                                {isLoading && (
                                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                )}
                                {currentRole === "TUTOR" ? "Join as Tutor" : "Sign Up"}
                            </button>
                        </div>
                    </form>

                </div>
            </div>
            <div className="mt-8 text-center">
                <Link href="/" className="text-sm text-gray-500 hover:text-gray-900 flex items-center justify-center gap-1">
                    <ArrowLeft className="w-4 h-4" /> Back to Home
                </Link>
            </div>
        </div>
    )
}
