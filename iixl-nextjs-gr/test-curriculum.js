const { connectMongo } = require("./backend/src/db/mongo.js");
const mongoose = require("mongoose");

async function run() {
    await connectMongo();
    const db = mongoose.connection.db;
    const filterCondition = { type: { $exists: false }, parts: { $exists: false } };
    const grades = await db.collection("grades").find(filterCondition).toArray();
    console.log("Grades:", grades.length);
    console.log("Grade 0:", grades[0]);
    process.exit(0);
}
run();
