const express = require("express");
const mongoose = require("mongoose");
const { connectMongo } = require("../db/mongo");

const router = express.Router();

function qFilter(microSkillId) {
  return {
    $or: [
      { microSkillId },
      { micro_skill_id: microSkillId },
      { microskill_id: microSkillId },
    ],
  };
}

router.get("/", async (req, res) => {
  try {
    await connectMongo();
    const db = mongoose.connection.db;
    const microSkillId = String(req.query.microSkillId || req.query.microskillId || "").trim();
    const limit = Math.min(200, Math.max(1, Number(req.query.limit || 80)));
    if (!microSkillId) return res.status(400).json({ error: "microSkillId is required." });

    const rows = await db
      .collection("questions")
      .find(qFilter(microSkillId))
      .sort({ sortOrder: 1, sort_order: 1, idx: 1, created_at: 1, _id: 1 })
      .limit(limit)
      .toArray();

    return res.json({ rows: rows.map((r) => ({ ...r, id: String(r.id || r._id) })), skillColumn: "microSkillId" });
  } catch (error) {
    return res.status(500).json({ error: error?.message || "Could not fetch questions." });
  }
});

router.post("/", async (req, res) => {
  try {
    await connectMongo();
    const db = mongoose.connection.db;
    const body = req.body || {};
    const microSkillId = String(body.microSkillId || body.micro_skill_id || body.microskill_id || "").trim();
    if (!microSkillId) return res.status(400).json({ error: "microSkillId is required." });

    const row = {
      ...body,
      microSkillId,
      micro_skill_id: microSkillId,
      microskill_id: microSkillId,
      id: String(body.id || new mongoose.Types.ObjectId()),
      created_at: body.created_at || new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    await db.collection("questions").insertOne(row);
    return res.json({ row, skillColumn: "microSkillId" });
  } catch (error) {
    return res.status(500).json({ error: error?.message || "Failed to create question." });
  }
});

router.delete("/", async (req, res) => {
  try {
    await connectMongo();
    const db = mongoose.connection.db;
    const id = String(req.body?.id || "").trim();
    if (!id) return res.status(400).json({ error: "id is required." });

    const result = await db.collection("questions").deleteOne({
      $or: [{ id }, ...(mongoose.Types.ObjectId.isValid(id) ? [{ _id: new mongoose.Types.ObjectId(id) }] : [])],
    });

    if (result.deletedCount === 0) return res.status(404).json({ error: "Question not found." });
    return res.json({ ok: true });
  } catch (error) {
    return res.status(500).json({ error: error?.message || "Failed to delete question." });
  }
});

module.exports = router;
