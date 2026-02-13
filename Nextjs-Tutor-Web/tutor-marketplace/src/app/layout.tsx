
import type { Metadata } from 'next'
import './globals.css'
import { Outfit } from 'next/font/google' // Changed to Outfit as per "Design Aesthetics" rule
import { Header } from '@/components/layout/Header'
import { Footer } from '@/components/layout/Footer'

const font = Outfit({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'TutorSpace - Find Expert Private Tutors',
  description: 'Connect with verified tutors for any subject, anywhere.',
  icons: {
    icon: '/favicon.ico',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={font.className}>
        <div className="flex flex-col min-h-screen">
          {/* Header is handled in individual pages or we can put it here if we want it global. 
                However, dashboard pages usually have different headers. 
                For now, let's keep it here but we might conditionally hide it for /dashboard later.
            */}
          {/* Note: In a real app we'd check pathname to conditionally render Header/Footer */}
          {children}
        </div>
      </body>
    </html>
  )
}
