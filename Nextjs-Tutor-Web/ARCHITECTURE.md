# Tutor Marketplace - Technical Architecture

## 1. Executive Summary
This project represents a high-performance, SEO-optimized Tutor Marketplace built with Next.js 15 (App Router), Tailwind CSS, and TypeScript. The platform serves two distinct user types: **Parents** (seeking tutors) and **Tutors** (offering services).

## 2. Technology Stack
- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS (with `lucide-react` for icons)
- **Authentication**: NextAuth.js (v5) - Handling dual roles (Parent/Tutor).
- **Database**: Supabase (PostgreSQL) accessed via Prisma ORM.
- **Forms**: React Hook Form + Zod validation
- **State Management**: React Context (minimal) + SWR/TanStack Query if needed.

## 3. SEO Strategy
- **Metadata API**: Dynamic generation of `title`, `description`, and `openGraph` tags.
- **Structured Data (JSON-LD)**: Schema markup for Organization, Person/Tutor, and Product.
- **Sitemap**: Auto-generated.

## 4. Database Schema (Prisma + Supabase)
### Models
- **User**: Base credentials (email, password hash, role).
- **Profile**: Tutor-specific details.
- **Review**: Ratings and comments.
- **Booking**: Session management.

## 5. Project Structure
Standard Next.js App Router structure with feature-based organization.
