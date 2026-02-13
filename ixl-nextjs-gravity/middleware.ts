
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
    let response = NextResponse.next({
        request: {
            headers: request.headers,
        },
    })

    // AUTH DISABLED FOR DEMO - BYPASS ALL CHECKS
    // The user requested to "comment out auth feature" and show a direct flow.
    return response

    // Prevent middleware crash if Supabase keys are not set yet
    // if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
    //     // console.warn("Supabase keys missing. Middleware skipping authentication checks.");
    //     return response;
    // }

    // const supabase = createServerClient(
    //     process.env.NEXT_PUBLIC_SUPABASE_URL!,
    //     process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    //     {
    //         cookies: {
    //             getAll() {
    //                 return request.cookies.getAll()
    //             },
    //             setAll(cookiesToSet) {
    //                 cookiesToSet.forEach(({ name, value, options }) => request.cookies.set(name, value))
    //                 response = NextResponse.next({
    //                     request: {
    //                         headers: request.headers,
    //                     },
    //                 })
    //                 cookiesToSet.forEach(({ name, value, options }) =>
    //                     response.cookies.set(name, value, options)
    //                 )
    //             },
    //         },
    //     }
    // )

    // const {
    //     data: { user },
    // } = await supabase.auth.getUser()

    // if (request.nextUrl.pathname.startsWith('/dashboard') || request.nextUrl.pathname.startsWith('/practice')) {
    //     if (!user) {
    //         // Uncomment to protect routes
    //         // return NextResponse.redirect(new URL('/login', request.url))
    //     }
    // }

    // if (request.nextUrl.pathname === '/login' || request.nextUrl.pathname === '/register') {
    //     if (user) {
    //         return NextResponse.redirect(new URL('/dashboard', request.url))
    //     }
    // }

    // return response
}

export const config = {
    matcher: ['/dashboard/:path*', '/practice/:path*', '/auth/:path*', '/login', '/register'],
}
