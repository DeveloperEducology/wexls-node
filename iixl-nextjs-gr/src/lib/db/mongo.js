const mongoose = require("mongoose");
const path = require("path");

// Resolve path relative to this file to ensure it's always found regardless of cwd
const envPath = path.resolve(__dirname, "../../.env.local");
require("dotenv").config({ path: envPath });

// Fallback to load root .env.local if backend one is missing
require("dotenv").config({ path: path.resolve(__dirname, "../../../../.env.local") });

let cached = global.mongoose;

if (!cached) {
  cached = global.mongoose = { conn: null, promise: null };
}

const connectDB = async () => {
  if (cached.conn) {
    return cached.conn;
  }

  if (mongoose.connection.readyState >= 1) {
    return mongoose.connection;
  }

  try {
    const uri = process.env.MONGODB_URI;
    if (!uri) throw new Error("MONGODB_URI not defined in environment variables");

    if (!cached.promise) {
      cached.promise = mongoose.connect(uri).then((mongooseInstance) => {
        console.log("MongoDB connected successfully");
        return mongooseInstance.connection;
      });
    }

    cached.conn = await cached.promise;
    return cached.conn;
  } catch (error) {
    console.error("MongoDB connection error:", error);
    cached.promise = null; // Re-attempt on next call
    // Don't exit process if running inside another app or dev environment
    if (require.main === module) process.exit(1);
    throw error;
  }
};

module.exports = { connectMongo: connectDB, connectDB };
