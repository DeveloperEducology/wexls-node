const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
require('dotenv').config({ path: '.env.local' });

const baseUrl = 'http://localhost:3000'; // Make sure this is where your app is running

async function testFilter() {
    const student1 = "01a2c113-0b50-470e-b13e-12d1ae354dc2";
    const student2 = "some-random-id-that-should-have-zero-data";

    console.log("Testing student 1 (real data expected):", student1);
    const res1 = await fetch(`${baseUrl}/api/adaptive/analytics/my-summary`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ studentId: student1 })
    });
    const data1 = await res1.json();
    console.log("Student 1 Result:", data1);

    console.log("\nTesting student 2 (zero data expected):", student2);
    const res2 = await fetch(`${baseUrl}/api/adaptive/analytics/my-summary`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ studentId: student2 })
    });
    const data2 = await res2.json();
    console.log("Student 2 Result:", data2);
}

testFilter().catch(console.error);
