const express = require('express');
const crypto = require('crypto');
const mongoose = require('mongoose');
const { connectMongo } = require('../db/mongo');
const { normalizeQuestionDoc, validateAnswer, buildFeedback } = require('../lib/question-utils');

const router = express.Router();

function makeSessionId(studentId, microskillId) {
  const sid = String(studentId || '').trim();
  const mid = String(microskillId || '').trim();
  if (!sid || !mid) return crypto.randomUUID();
  return `${sid}:${mid}`;
}

async function fetchQuestionsByMicroskill(microskillId) {
  await connectMongo();
  const db = mongoose.connection.db;
  const rows = await db.collection('questions')
    .find({
      $or: [
        { microSkillId: microskillId },
        { micro_skill_id: microskillId },
        { microskill_id: microskillId },
      ],
    })
    .sort({ sortOrder: 1, sort_order: 1, idx: 1, created_at: 1, _id: 1 })
    .toArray();

  return rows.map(normalizeQuestionDoc);
}

function pickNext(questions, { recentQuestionIds = [], excludeQuestionId = null } = {}) {
  const recent = new Set((recentQuestionIds || []).map(String));
  const candidates = questions.filter((q) => String(q.id) !== String(excludeQuestionId || ''));
  const unseen = candidates.filter((q) => !recent.has(String(q.id)));
  if (unseen.length > 0) return unseen[0];
  if (candidates.length > 0) return candidates[Math.floor(Math.random() * candidates.length)];
  return null;
}

router.post('/session/start', async (req, res) => {
  try {
    await connectMongo();
    const db = mongoose.connection.db;

    const studentId = String(req.body?.studentId || '').trim();
    const microskillId = String(req.body?.microSkillId || '').trim();
    const providedSessionId = String(req.body?.sessionId || '').trim();

    if (!studentId || !microskillId) {
      return res.status(400).json({ error: 'studentId and microSkillId are required.' });
    }

    const sessionId = providedSessionId || makeSessionId(studentId, microskillId);
    const nowIso = new Date().toISOString();

    await db.collection('adaptive_sessions').updateOne(
      { id: sessionId },
      {
        $set: {
          id: sessionId,
          student_id: studentId,
          micro_skill_id: microskillId,
          phase: 'warmup',
          updated_at: nowIso,
        },
        $setOnInsert: {
          recent_question_ids: [],
          created_at: nowIso,
        },
      },
      { upsert: true }
    );

    const sessionState = await db.collection('adaptive_sessions').findOne({ id: sessionId });

    return res.json({
      sessionId,
      phase: sessionState?.phase || 'warmup',
      studentSkillState: {
        student_id: studentId,
        micro_skill_id: microskillId,
      },
      sessionState,
    });
  } catch (error) {
    return res.status(500).json({ error: error?.message || 'Failed to start adaptive session.' });
  }
});

router.post('/next-question', async (req, res) => {
  try {
    await connectMongo();
    const db = mongoose.connection.db;

    const sessionId = String(req.body?.sessionId || '').trim();
    const studentId = String(req.body?.studentId || '').trim();
    const microskillId = String(req.body?.microSkillId || '').trim();

    if (!sessionId || !studentId || !microskillId) {
      return res.status(400).json({ error: 'sessionId, studentId and microSkillId are required.' });
    }

    const session = await db.collection('adaptive_sessions').findOne({ id: sessionId });
    const questions = await fetchQuestionsByMicroskill(microskillId);
    const question = pickNext(questions, { recentQuestionIds: session?.recent_question_ids || [] });

    if (!question) {
      return res.status(404).json({ error: 'No adaptive questions available for this microskill.' });
    }

    const prevRecent = Array.isArray(session?.recent_question_ids) ? session.recent_question_ids.map(String) : [];
    const recentSet = new Set(prevRecent);
    recentSet.delete(String(question.id)); // move to end
    recentSet.add(String(question.id));
    const recent = Array.from(recentSet).slice(-40);

    await db.collection('adaptive_sessions').updateOne(
      { id: sessionId },
      {
        $set: {
          recent_question_ids: recent,
          updated_at: new Date().toISOString(),
        },
      }
    );

    return res.json({
      question,
      selectionMeta: {
        policy: 'mongo_sequence',
        phase: session?.phase || 'warmup',
        reason: 'next_unseen_or_first',
      },
    });
  } catch (error) {
    return res.status(500).json({ error: error?.message || 'Failed to select adaptive question.' });
  }
});

router.post('/submit-and-next', async (req, res) => {
  try {
    await connectMongo();
    const db = mongoose.connection.db;

    const sessionId = String(req.body?.sessionId || '').trim();
    const studentId = String(req.body?.studentId || '').trim();
    const microskillId = String(req.body?.microSkillId || '').trim();
    const questionId = String(req.body?.questionId || '').trim();
    const answer = req.body?.answer ?? null;

    if (!sessionId || !studentId || !microskillId || !questionId) {
      return res.status(400).json({ error: 'sessionId, studentId, microSkillId and questionId are required.' });
    }

    const session = await db.collection('adaptive_sessions').findOne({ id: sessionId });
    const questions = await fetchQuestionsByMicroskill(microskillId);
    const currentQuestion = questions.find((q) => String(q.id) === questionId);
    if (!currentQuestion) {
      return res.status(404).json({ error: 'Current question not found.' });
    }

    const isCorrect = validateAnswer(currentQuestion, answer);
    const feedback = buildFeedback(currentQuestion);

    const prevRecent = Array.isArray(session?.recent_question_ids) ? session.recent_question_ids.map(String) : [];
    const recentSet = new Set(prevRecent);
    recentSet.delete(String(questionId));
    recentSet.add(String(questionId));
    const recent = Array.from(recentSet).slice(-40);

    await db.collection('attempt_events').insertOne({
      session_id: sessionId,
      student_id: studentId,
      micro_skill_id: microskillId,
      question_id: questionId,
      is_correct: isCorrect,
      answer_payload: answer,
      created_at: new Date().toISOString(),
    });

    const phase = isCorrect ? 'core' : 'recovery';

    const nextQuestion = pickNext(questions, {
      recentQuestionIds: recent,
      excludeQuestionId: questionId,
    });

    if (nextQuestion) {
      recentSet.delete(String(nextQuestion.id));
      recentSet.add(String(nextQuestion.id));
    }
    const finalRecent = Array.from(recentSet).slice(-40);

    await db.collection('adaptive_sessions').updateOne(
      { id: sessionId },
      {
        $set: {
          phase,
          recent_question_ids: finalRecent,
          last_question_id: questionId,
          updated_at: new Date().toISOString(),
        },
      },
      { upsert: true }
    );

    return res.json({
      isCorrect,
      feedback,
      nextQuestion,
      sessionUpdate: { phase },
      selectionMeta: {
        policy: 'mongo_sequence',
        phase,
        reason: isCorrect ? 'correct_progression' : 'incorrect_recovery',
      },
    });
  } catch (error) {
    return res.status(500).json({ error: error?.message || 'Failed to submit adaptive answer.' });
  }
});

module.exports = router;
