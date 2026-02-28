const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const { connectMongo } = require("./src/db/mongo");
const practiceRoutes = require("./src/routes/practice-routes");
const adaptiveRoutes = require("./src/routes/adaptive-routes");
const adminQuestionRoutes = require("./src/routes/admin-question-routes");
const curriculumRoutes = require("./src/routes/curriculum-routes");

const path = require("path");

dotenv.config({ path: path.resolve(__dirname, ".env.local") });
dotenv.config({ path: path.resolve(__dirname, "../.env.local") }); // fallback to root
dotenv.config();
const app = express();
const PORT = Number(process.env.BACKEND_PORT || 4000);

app.use(cors());
app.use(express.json({ limit: "1mb" }));

app.get("/api", (req, res) => {
  res.json({
    ok: true,
    service: "wexls-backend",
    endpoints: [
      "/api/health",
      "/api/practice/:microskillId",
      "/api/practice/:microskillId/submit",
      "/api/adaptive/session/start",
      "/api/adaptive/next-question",
      "/api/adaptive/submit-and-next",
      "/api/admin/questions",
      "/api/curriculum",
    ],
  });
});

app.get("/api/health", async (req, res) => {
  try {
    await connectMongo();
    return res.json({ ok: true, db: "connected", timestamp: new Date().toISOString() });
  } catch (error) {
    return res.status(503).json({
      ok: false,
      db: "disconnected",
      error: error?.message || "MongoDB unavailable",
    });
  }
});

app.use("/api/practice", practiceRoutes);
app.use("/api/adaptive", adaptiveRoutes);
app.use("/api/admin/questions", adminQuestionRoutes);
app.use("/api/curriculum", curriculumRoutes);

app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err?.message || "Internal server error" });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Backend listening on http://localhost:${PORT}`);
    connectMongo()
      .then(() => {
        console.log("MongoDB connected");
      })
      .catch((error) => {
        console.error("MongoDB connection failed:", error?.message || error);
      });
  });
}

module.exports = app;
