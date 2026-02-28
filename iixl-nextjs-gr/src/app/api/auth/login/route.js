import { NextResponse } from 'next/server';
import { connectMongo } from '@/lib/db/mongo';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

export async function POST(req) {
    try {
        const { email, password } = await req.json();

        if (!email || !password) {
            return NextResponse.json({ error: 'Email and password are required' }, { status: 400 });
        }

        await connectMongo();
        const db = mongoose.connection.db;

        const user = await db.collection('users').findOne({ email: email.trim().toLowerCase() });

        if (!user || !user.password_hash) {
            return NextResponse.json({ error: 'Invalid email or password' }, { status: 401 });
        }

        const isValidPassword = await bcrypt.compare(password, user.password_hash);

        if (!isValidPassword) {
            return NextResponse.json({ error: 'Invalid email or password' }, { status: 401 });
        }

        return NextResponse.json({
            user: {
                id: user.id || user._id,
                email: user.email,
                user_metadata: {
                    name: user.name,
                    birthYear: user.birth_year,
                    gradeId: user.grade_id
                }
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
    }
}
