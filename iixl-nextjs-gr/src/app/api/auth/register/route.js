import { NextResponse } from 'next/server';
import { connectMongo } from '@/lib/db/mongo';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

export async function POST(req) {
    try {
        const { email, password, name, birthYear, gradeId } = await req.json();

        if (!email || !password) {
            return NextResponse.json({ error: 'Email and password are required' }, { status: 400 });
        }

        if (password.length < 6) {
            return NextResponse.json({ error: 'Password must be at least 6 characters' }, { status: 400 });
        }

        await connectMongo();
        const db = mongoose.connection.db;

        // Check if user exists
        const existingUser = await db.collection('users').findOne({ email: email.trim().toLowerCase() });
        if (existingUser) {
            return NextResponse.json({ error: 'User with this email already exists' }, { status: 409 });
        }

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const passwordHash = await bcrypt.hash(password, salt);

        const now = new Date().toISOString();

        // UUID v4 format generator
        const uuid = crypto.randomUUID();

        const newUser = {
            _id: uuid,  // Using UUID for ID to match existing Supabase id shape
            id: uuid,
            email: email.trim().toLowerCase(),
            password_hash: passwordHash,
            name: name || email.split('@')[0],
            birth_year: birthYear || null,
            grade_id: gradeId || null,
            created_at: now,
            updated_at: now
        };

        await db.collection('users').insertOne(newUser);

        // Return user without password hash
        const { password_hash, ...userProfile } = newUser;

        return NextResponse.json({
            user: {
                id: userProfile.id,
                email: userProfile.email,
                user_metadata: {
                    name: userProfile.name,
                    birthYear: userProfile.birth_year,
                    gradeId: userProfile.grade_id
                }
            }
        });
    } catch (error) {
        console.error('Registration error:', error);
        return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
    }
}
