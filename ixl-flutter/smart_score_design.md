# IXL-Style Smart Scoring System Design

## 1. Philosophy & Algorithm
The SmartScore is a measure of **capability**, not just volume. It represents the probability that a student can answer a question of a certain difficulty correctly.

### Growth Curves (The "Staged" Approach)
Instead of a single formula, we specific distinct **Stages of Learning**.

| Score Range | Stage Name | Base Gain (Correct) | Base Penalty (Incorrect) | Logic |
| :--- | :--- | :--- | :--- | :--- |
| **0 - 40** | **Exploration** | +10 | -2 | Encourages trying. Mistakes are cheap. Fast initial progress motivation. |
| **40 - 70** | **Practice** | +6 | -4 | Building core skills. Balanced risk/reward. |
| **70 - 90** | **Proficiency** | +4 | -6 | Proving consistency. Mistakes clearly set you back. |
| **90 - 100** | **Mastery** | +1 to +2 | -8 | The "Challenge Zone". Requires near-perfect streak. One slip is significant. |

### 2. Difficulty Scaling (Adaptive)
The system adapts the question difficulty based on the current SmartScore.

*   **Score 0-50**: Serves **Easy** questions.
*   **Score 50-80**: Serves **Medium** questions.
*   **Score 80+**: Serves **Hard** questions.

**Difficulty Multipliers:**
If a student answers a question that is *harder* than their current level expects, they get a bonus.
*   Question Difficulty > User Level: **1.5x Gain** / **0.5x Penalty** (Bravery bonus)
*   Question Difficulty < User Level: **0.5x Gain** / **1.5x Penalty** (Sandbagging penalty)

### 3. Streak Mechanics
A `streak` counter tracks consecutive correct answers.
*   **Streak Bonus**: `gain = base_gain + (streak * 0.5)` (Capped at +3 extra).
*   **Safety Net**: If a student is on a streak of 5+, a mistake only applies **50% of the normal penalty** (The "Oops" protection). Reset streak after use.

### 4. The "Challenge Mode" (90-100)
To reach 100, the user enters a special state.
*   Questions are strictly **Hard**.
*   Gain is fixed at +1 or +2.
*   Formula: `NewScore = CurrentScore + 1`.
*   Incorrect answer drops user back to **85-90** immediately (The "Gladiator Rule").
*   100 is achieved only after N successful Challenge questions.

## 5. Mathematical Pseudocode

```dart
function calculateNextScore(currentScore, isCorrect, questionDifficulty, userStreak) {
    
    // 1. Determine Stage
    GameState stage;
    if (currentScore < 40) stage = Exploration;
    else if (currentScore < 70) stage = Practice;
    else if (currentScore < 90) stage = Proficiency;
    else stage = Mastery;

    // 2. Base Values
    int gain, penalty;
    switch(stage) {
        case Exploration: gain = 10; penalty = 2; break;
        case Practice:    gain = 6;  penalty = 4; break;
        case Proficiency: gain = 4;  penalty = 6; break;
        case Mastery:     gain = 2;  penalty = 8; break; 
    }

    // 3. Difficulty Multiplier (Simplified)
    // Assume we align question serving with score, so usually 1.0
    // If user solves HARD while in Exploration:
    // gain = gain * 1.5;
    
    // 4. Calculate
    if (isCorrect) {
        // Streak Bonus
        int bonus = min(userStreak, 5) * 0.5; // Up to +2.5
        
        int finalChart = currentScore + gain + bonus;
        return min(finalChart, 100);
    } else {
        // Streak Protection
        if (userStreak >= 5) penalty = penalty / 2;
        
        int finalChart = currentScore - penalty;
        // Floor checks
        if (stage == Mastery && finalChart < 80) finalChart = 85; // Soft landing for masters
        if (finalChart < 0) finalChart = 0;
        
        return finalChart;
    }
}
```

## 6. Data Model

The user's progress should be stored per skill.

```sql
CREATE TABLE skill_progress (
    user_id UUID,
    micro_skill_id UUID,
    smart_score INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    questions_answered INTEGER DEFAULT 0,
    last_difficulty TEXT DEFAULT 'easy',
    history JSONB, -- Logs of last 5 scores for graphing
    PRIMARY KEY (user_id, micro_skill_id)
);
```
