const express = require("express");
const { connectMongo } = require("../db/mongo");
const { normalizeQuestionDoc, validateAnswer, buildFeedback } = require("../lib/question-utils");

const router = express.Router();

async function fetchQuestions(microskillId) {
  await connectMongo();
  const db = require("mongoose").connection.db;
  const matchFilter = {
    $or: [
      { microSkillId: microskillId },
      { micro_skill_id: microskillId },
      { microskill_id: microskillId },
    ],
  };

  const rows = await db
    .collection("questions")
    .find(matchFilter)
    .sort({ sortOrder: 1, sort_order: 1, idx: 1, created_at: 1, _id: 1 })
    .toArray();

  console.log(`[Practice API] Requested microskillId: "${microskillId}" (type: ${typeof microskillId}) -> Found ${rows.length} questions`);

  return rows.map(normalizeQuestionDoc);
}

router.get("/:microskillId", async (req, res) => {
  try {
    const microskillId = String(req.params.microskillId || "").trim();
    if (!microskillId) return res.status(400).json({ error: "microskillId is required." });

    const questions = await fetchQuestions(microskillId);
    const randomIndex = questions.length > 0 ? Math.floor(Math.random() * questions.length) : 0;
    return res.json({ source: "mongodb", question: questions[randomIndex] || null });
  } catch (error) {
    const message = String(error?.message || "Failed to fetch question.");
    const status = /auth|ENOTFOUND|ECONNREFUSED|timed out|querySrv/i.test(message) ? 503 : 500;
    return res.status(status).json({ error: message });
  }
});

router.post("/:microskillId/submit", async (req, res) => {
  try {
    const microskillId = String(req.params.microskillId || "").trim();
    const { questionId, answer = null, seenQuestionIds = [], studentId = null, responseMs = 0 } = req.body || {};
    if (!microskillId) return res.status(400).json({ error: "microskillId is required." });
    if (!questionId) return res.status(400).json({ error: "questionId is required." });

    const questions = await fetchQuestions(microskillId);
    const current = questions.find((q) => String(q.id) === String(questionId));
    if (!current) return res.status(404).json({ error: "Question not found for this microskill." });

    const isCorrect = validateAnswer(current, answer);
    const feedback = buildFeedback(current);

    const seen = new Set(Array.isArray(seenQuestionIds) ? seenQuestionIds.map(String) : []);
    seen.add(String(questionId));
    let next = questions.find((q) => !seen.has(String(q.id)) && String(q.id) !== String(questionId)) || null;
    if (!next) {
      const candidates = questions.filter((q) => String(q.id) !== String(questionId));
      if (candidates.length > 0) {
        next = candidates[Math.floor(Math.random() * candidates.length)];
      }
    }

    if (studentId) {
      const db = require("mongoose").connection.db;
      await db.collection("student_question_log").insertOne({
        student_id: String(studentId),
        micro_skill_id: microskillId,
        question_id: String(questionId),
        is_correct: isCorrect,
        response_ms: Number(responseMs || 0),
        answer_payload: answer,
        created_at: new Date().toISOString(),
      });
    }

    return res.json({ source: "mongodb", isCorrect, feedback, nextQuestion: next });
  } catch (error) {
    const message = String(error?.message || "Failed to submit answer.");
    const status = /auth|ENOTFOUND|ECONNREFUSED|timed out|querySrv/i.test(message) ? 503 : 500;
    return res.status(status).json({ error: message });
  }
});

module.exports = router;
