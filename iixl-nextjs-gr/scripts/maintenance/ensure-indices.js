const { MongoClient } = require('mongodb');
require('dotenv').config({ path: '.env.local' });

const uri = process.env.MONGODB_URI;

async function run() {
    const client = new MongoClient(uri);
    try {
        await client.connect();
        const db = client.db(); // uses database from connection string

        console.log('--- Ensuring Users Indices ---');
        await db.collection('users').createIndex({ email: 1 }, { unique: true });
        await db.collection('users').createIndex({ id: 1 }, { unique: true });

        console.log('--- Ensuring Analytics/Attempt Indices ---');
        await db.collection('attempt_events').createIndex({ student_id: 1, created_at: -1 });
        await db.collection('attempt_events').createIndex({ session_id: 1 });
        await db.collection('attempt_events').createIndex({ student_id: 1, micro_skill_id: 1 });

        await db.collection('student_question_log').createIndex({ student_id: 1, created_at: -1 });
        await db.collection('student_question_log').createIndex({ student_id: 1, microskill_id: 1 });

        await db.collection('student_skill_state').createIndex({ student_id: 1, micro_skill_id: 1 }, { unique: true });

        console.log('--- Ensuring Curriculum Indices ---');
        await db.collection('microskills').createIndex({ id: 1 }, { unique: true });
        await db.collection('microskills').createIndex({ unit_id: 1 });

        console.log('All indices checked/created successfully.');
    } catch (err) {
        console.error('Error creating indices:', err);
    } finally {
        await client.close();
    }
}

run();
