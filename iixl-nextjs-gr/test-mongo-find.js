const mongoose = require("mongoose");
require("dotenv").config({ path: ".env.local" });

async function test() {
  await mongoose.connect(process.env.MONGODB_URI);
  const db = mongoose.connection.db;
  const count = await db.collection("questions").countDocuments({ micro_skill_id: "6c3f3378-468f-41cc-a98f-c77540f61d9c" });
  console.log("Questions for 6c3f:", count);

  const count2 = await db.collection("questions").countDocuments({ micro_skill_id: "3850f791-3ba4-4291-8c84-46cdb1f57229" });
  console.log("Questions for 3850:", count2);

  process.exit(0);
}
test();
