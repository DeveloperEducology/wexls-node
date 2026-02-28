const mongoose = require("mongoose");
require("dotenv").config({ path: ".env.local" });

async function test() {
  await mongoose.connect(process.env.MONGODB_URI);
  const db = mongoose.connection.db;
  const questions = await db.collection("questions").find({}).limit(1).toArray();
  console.log(JSON.stringify(questions, null, 2));
  process.exit(0);
}
test();
