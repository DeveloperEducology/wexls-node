const { normalizeQuestionDoc } = require('./backend/src/lib/question-utils.js');
const qn = {
  "_id": {
    "$oid": "699fc218b6b783dff17e6278"
  },
  "idx": 23,
  "id": "ae4347de-9bec-464b-9e5c-906a545d30af",
  "micro_skill_id": "3850f791-3ba4-4291-8c84-46cdb1f57229",
  "type": "fillInTheBlank",
  "parts": "[{\"id\": \"title\", \"type\": \"text\", \"content\": \"What is 793 multiplied by 3?\", \"hasAudio\": false, \"isVertical\": true}, {\"id\": \"r1_t\", \"type\": \"text\", \"content\": \"700 x 3 =\", \"hasAudio\": false, \"isVertical\": false}, {\"id\": \"r1_a\", \"type\": \"input\", \"width\": \"110px\", \"hasAudio\": false, \"maxLength\": 4, \"answerType\": \"number\", \"isVertical\": false}, {\"id\": \"r1_br\", \"type\": \"text\", \"content\": \" \", \"hasAudio\": false, \"isVertical\": true}, {\"id\": \"r2_t\", \"type\": \"text\", \"content\": \"90 x 3 =\", \"hasAudio\": false, \"isVertical\": false}, {\"id\": \"r2_a\", \"type\": \"input\", \"width\": \"110px\", \"hasAudio\": false, \"maxLength\": 3, \"answerType\": \"number\", \"isVertical\": false}, {\"id\": \"r2_br\", \"type\": \"text\", \"content\": \" \", \"hasAudio\": false, \"isVertical\": true}, {\"id\": \"r3_t\", \"type\": \"text\", \"content\": \"3 x 3 =\", \"hasAudio\": false, \"isVertical\": false}, {\"id\": \"r3_a\", \"type\": \"input\", \"width\": \"110px\", \"hasAudio\": false, \"maxLength\": 1, \"answerType\": \"number\", \"isVertical\": false}, {\"id\": \"r3_br\", \"type\": \"text\", \"content\": \" \", \"hasAudio\": false, \"isVertical\": true}, {\"id\": \"r4_t\", \"type\": \"text\", \"content\": \"Total =\", \"hasAudio\": false, \"isVertical\": false}, {\"id\": \"r4_a\", \"type\": \"input\", \"width\": \"110px\", \"hasAudio\": false, \"maxLength\": 4, \"answerType\": \"number\", \"isVertical\": false}]",
  "options": "[]",
  "correct_answer_index": -1,
  "correct_answer_text": "{\"r1_a\": \"2100\", \"r2_a\": \"270\", \"r3_a\": \"9\", \"r4_a\": \"2379\"}",
  "solution": "700×3=2100, 90×3=270, 3×3=9, total = 2379.",
  "difficulty": "medium",
  "marks": 1,
  "created_at": "2026-02-23 05:27:18.833588+00",
  "drag_groups": "[]",
  "drag_items": "[]",
  "sub_topic": null,
  "complexity": 10,
  "is_multi_select": false,
  "correct_answer_indices": null,
  "is_vertical": false,
  "show_submit_button": false,
  "adaptive_config": "{\"inputMode\": \"digit_pad\", \"phaseHint\": \"challenge\", \"conceptTags\": [\"multiplication\", \"partial_products\", \"place_value\"], \"isRemediation\": false, \"policyVersion\": \"misconception_v2\", \"remediationLevel\": 0, \"misconceptionCode\": \"partial_products_addition_error\", \"targetComplexityBand\": \"mid_high\"}",
  "solutionParts": null,
  "question_text": null
};

try {
  const norm = normalizeQuestionDoc(qn);
  console.log(JSON.stringify(norm, null, 2));
} catch (e) {
  console.error("Error normalizing:", e);
}
