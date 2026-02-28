const mongoose = require("mongoose");
async function test() {
  try {
    const uriRoots = "mongodb+srv://vjymrk:Admin_84529@cluster0.ivjiolu.mongodb.net/wexls?retryWrites=true&w=majority";
    await mongoose.createConnection(uriRoots).asPromise();
    console.log("Root URI connected successfully!");
  } catch(e) { console.error("Root URI failed:", e.message); }

  try {
    const uriBackend = "mongodb+srv://vijay:Admin_84529@cluster0.ivjiolu.mongodb.net/wexls?retryWrites=true&w=majority";
    await mongoose.createConnection(uriBackend).asPromise();
    console.log("Backend URI connected successfully!");
  } catch(e) { console.error("Backend URI failed:", e.message); }
  process.exit(0);
}
test();
