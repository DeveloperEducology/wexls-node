# IXL Learning - Next.js Migration Documentation

This document outlines the architecture, technology stack, and implementation plan for migrating the IXL Flutter application to a Next.js web application.

## 1. Technology Stack

- **Framework**: [Next.js 14+](https://nextjs.org/) (App Router)
- **Language**: [TypeScript](https://www.typescriptlang.org/)
- **Styling**: [Tailwind CSS](https://tailwindcss.com/)
- **Backend & Auth**: [Supabase](https://supabase.com/) (Existing)
- **State Management**: React Context + Hooks (or Zustand for complex global state)
- **Data Fetching**: SWR or TanStack Query
- **Icons**: Lucide React or Heroicons
- **Drag & Drop**: [dnd-kit](https://dndkit.com/) (Recommended for modern, accessible drag & drop)
- **Math Rendering**: `react-latex-next` or `katex`

## 2. Project Structure (App Router)

```
app/
├── layout.tsx              # Root layout (Auth provider, Toaster, etc.)
├── page.tsx                # Landing page (Redirects to /dashboard or /login)
├── (auth)/                 # Auth Route Group
│   ├── login/
│   │   └── page.tsx
│   └── register/
│       └── page.tsx
├── (dashboard)/            # Protected Routes
│   ├── layout.tsx          # Dashboard shell (Sidebar, Header)
│   ├── dashboard/          # Home (Grade selection / Subjects)
│   │   └── page.tsx
│   ├── subjects/
│   │   └── [gradeId]/
│   │       └── [subjectId]/
│   │           └── page.tsx # List of Units & Skills
│   ├── practice/
│   │   └── [skillId]/
│   │       └── page.tsx    # Interactive Practice Session
│   └── profile/
│       └── page.tsx        # User stats and settings
components/
├── ui/                     # Reusable UI components (Buttons, Cards, Inputs)
├── auth/                   # Auth forms
├── layout/                 # Header, Sidebar
├── practice/               # Practice engine components
│   ├── QuestionRenderer.tsx
│   ├── MCQQuestion.tsx
│   ├── DragDropQuestion.tsx
│   ├── TextInputQuestion.tsx
│   └── Scoreboard.tsx
lib/
├── supabase/               # Supabase client & utilities
├── utils/                  # Helper functions
└── types/                  # TypeScript interfaces (Question, User, etc.)
hooks/                      # Custom hooks (useAuth, usePracticeSession)
```

## 3. Data Models (TypeScript Interfaces)

Based on existing Flutter models (`lib/features/practice/domain/models.dart`).

```typescript
// types/question.ts

export enum QuestionType {
  MCQ = 'mcq',
  TextInput = 'textInput',
  Sorting = 'sorting',
  DragAndDrop = 'dragAndDrop',
  FillInTheBlank = 'fillInTheBlank',
  FourPicsOneWord = 'fourPicsOneWord',
  ImageChoice = 'imageChoice',
}

export interface QuestionPart {
  type: 'text' | 'math' | 'image' | 'diagram' | 'input' | 'svg';
  content?: string;
  imageUrl?: string;
  width?: number;
  height?: number;
  children?: QuestionPart[];
}

export interface Option {
  text?: string;
  imageUrl?: string;
  id?: string;
}

export interface Question {
  id: string;
  type: QuestionType;
  parts: QuestionPart[];
  options: Option[];
  correctAnswerIndex: number;
  correctAnswerIndices?: number[]; // For multi-select
  correctAnswerText?: string;
  solution: string; // Explanation
  difficulty: 'easy' | 'medium' | 'hard';
  dragGroups?: DragDropGroup[];
  dragItems?: DragDropItem[];
}

export interface DragDropGroup {
  id: string;
  label: string;
  imageUrl?: string;
}

export interface DragDropItem {
  id: string;
  content: string;
  type: 'text' | 'image' | 'svg';
  targetGroupId: string;
}
```

## 4. Feature Implementation Details

### 4.1. Authentication
- Use `@supabase/auth-helpers-nextjs` for server-side and client-side auth.
- Middleware (`middleware.ts`) to protect dashboard routes.
- **Login/Register Pages**: Replicate the responsive split-screen design implemented in the Flutter Refactor.

### 4.2. Home & Dashboard
- **Grade Selection**: Check user profile `grade_id`. If null, show a modal or redirect to a setup page.
- **Subjects Grid**: Fetch subjects from `subjects` table filtered by grade.
- **Resume Card**: Fetch latest `practice_session` for the user. `Display smart_score` and `skill_name`.

### 4.3. Navigation (Drill Down)
1.  **Dashboard**: User clicks "Math".
2.  **Subject Page (`/subjects/[gradeId]/[subjectId]`)**:
    - Fetch `units` with nested `micro_skills`.
    - Render an Accordion or List view:
        - Unit 1: Algebra
            - Skill 1.1: Solve for x
            - Skill 1.2: Linear equations

### 4.4. Practice Engine (`/practice/[skillId]`)
This is the core complexity.
- **State**: `currentQuestionIndex`, `score` (SmartScore algorithm), `history`, `streak`.
- **Logic**:
    - Fetch questions by `micro_skill_id`.
    - Render `QuestionRenderer` based on `question.type`.
    - On Submit:
        - Validate answer locally (or via server function).
        - Update Score (SmartScore logic: +10 for correct, -X for wrong based on current score).
        - Show "Correct!" or "Sorry, incorrect..." feedback overlay.
        - Show Solution/Explanation.
    - Save progress to `practice_sessions` table on every answer or periodically.

---

## 5. Question Types - Complete Implementation Guide

The practice engine supports **7 different question types**. Each type has unique rendering requirements, validation logic, and user interaction patterns.

### 5.1. MCQ (Multiple Choice Question)

**Type Code**: `mcq`

**Description**: Single or multiple-select questions with text or image options.

**Data Structure**:
```typescript
{
  type: 'mcq',
  parts: QuestionPart[], // Question text, images, math
  options?: string[],     // Legacy text options
  richOptions: RichOption[], // Modern options (text + images)
  isMultiSelect: boolean,    // Allow multiple selections
  isVertical: boolean,       // Vertical list vs. grid layout
  showSubmitButton: boolean, // Require submit button or auto-submit on select
  correctAnswerIndex: number,        // For single select
  correctAnswerIndices?: number[],   // For multi-select
}
```

**Rendering**:
- **Layout Options**:
  - `isVertical: true` → Full-width vertical list
  - `isVertical: false` → Responsive grid (2-3 columns based on screen size)
- **Option Types**:
  - Text-only: Display in styled button
  - Image-only: Display image in card
  - Text + Image: Combined layout (image on left/top, text below/right)
- **Multi-Select**: Show checkbox icon in top-right corner of option
- **Selection State**: 
  - Selected: Green border (4px), light green background
  - Unselected: Light blue border (2px), white background

**Interaction**:
1. User clicks/taps option
2. If `isMultiSelect`: Toggle selection, wait for submit
3. If single + `!showSubmitButton`: Auto-submit immediately
4. Otherwise: Wait for manual submit button click

**Validation**:
```typescript
function validateMCQ(question: Question, userAnswer: number | number[]): boolean {
  if (question.isMultiSelect) {
    const correct = question.correctAnswerIndices || [];
    const selected = userAnswer as number[];
    return correct.length === selected.length && 
           correct.every(idx => selected.includes(idx));
  }
  return question.correctAnswerIndex === userAnswer;
}
```

---

### 5.2. Text Input

**Type Code**: `textInput`

**Description**: Numeric or text input questions with optional inline placement.

**Data Structure**:
```typescript
{
  type: 'textInput',
  parts: QuestionPart[], // Last part may be inline with input
  correctAnswerText: string, // Expected answer
}
```

**Rendering**:
- **Layout Detection**:
  - If last part is `text` or `math`: Merge input inline with question
  - Otherwise: Display input below question content
- **Input Field**:
  - Width: 80px (inline) or 150px (block)
  - Read-only with custom numeric keyboard (mobile-first approach)
  - Green border when focused, white/grey when inactive
  - Center-aligned text
- **Numeric Keyboard**:
  - Grid layout: 3 columns
  - Buttons: 0-9, backspace, submit
  - Shows below input when field is active

**Interaction**:
1. User taps input field → Activates field, shows numeric keyboard
2. User types digits → Updates field value
3. User taps submit or presses Enter → Validates answer

**Validation**:
```typescript
function validateTextInput(question: Question, userAnswer: string): boolean {
  // Normalize: trim, lowercase, remove extra spaces
  const normalize = (s: string) => s.trim().toLowerCase().replace(/\s+/g, ' ');
  return normalize(userAnswer) === normalize(question.correctAnswerText || '');
}
```

---

### 5.3. Sorting

**Type Code**: `sorting`

**Description**: Reorder items into correct sequence (drag-to-reorder).

**Data Structure**:
```typescript
{
  type: 'sorting',
  parts: QuestionPart[], // Instructions
  options: string[],     // Items to sort (in shuffled order)
  correctAnswerText: string, // Comma-separated correct order or JSON array
}
```

**Rendering**:
- **List Layout**: Vertical reorderable list
- **Item Style**:
  - White background, grey border
  - Drag handle icon (☰) on left
  - Drop shadow for depth
- **Drag Indicator**: Visual feedback during drag (elevated shadow)

**Interaction**:
1. User drags item by handle
2. List reorders in real-time (optimistic UI)
3. User clicks Submit to validate final order

**Validation**:
```typescript
function validateSorting(question: Question, userOrder: string[]): boolean {
  const correctOrder = JSON.parse(question.correctAnswerText || '[]');
  return JSON.stringify(userOrder) === JSON.stringify(correctOrder);
}
```

**Implementation Notes**:
- Use `dnd-kit`'s `SortableContext` for accessible drag-drop
- Provide keyboard navigation support (arrow keys + space to lift/place)

---

### 5.4. Drag and Drop (Group Assignment)

**Type Code**: `dragAndDrop`

**Description**: Drag items into categorized buckets/groups.

**Data Structure**:
```typescript
{
  type: 'dragAndDrop',
  parts: QuestionPart[], // Instructions
  groups: DragDropGroup[], // Target buckets
  dragItems: DragDropItem[], // Items to drag
}

interface DragDropGroup {
  id: string;
  label: string;
  imageUrl?: string; // Optional group icon
}

interface DragDropItem {
  id: string;
  content: string;      // Text, image URL, or SVG string
  type: 'text' | 'image' | 'svg';
  targetGroupId: string; // Correct group ID
}
```

**Rendering**:
- **Groups (Drop Zones)**:
  - Horizontal row of buckets (on desktop) or vertical stack (mobile)
  - Each bucket: Green border, min-height 200px
  - Group label at top, optional image below
  - Items inside bucket shown below divider
  - Highlight bucket (light green bg) when dragging item over it
- **Items**:
  - **Text**: Blue pill-shaped badge
  - **Image/SVG**: White card with image (80x80px, contain fit)
  - Show in "Source Area" (unassigned pool) initially
- **Source Area**:
  - Bottom section with grey border
  - Contains all unassigned items
  - Acts as drop zone to "unassign" items

**Interaction**:
1. User drags item from source or from a group
2. Drops into target group → Item moves to that group
3. Drops into source area → Item returns to unassigned pool
4. User clicks Submit to validate all assignments

**Validation**:
```typescript
function validateDragDrop(
  question: Question, 
  assignments: Record<string, string> // itemId -> groupId
): boolean {
  return question.dragItems.every(item => 
    assignments[item.id] === item.targetGroupId
  );
}
```

**Implementation Notes**:
- Use `dnd-kit`'s `DndContext` with multiple `Droppable` zones
- Handle both mouse and touch events
- Provide visual feedback during drag (semi-transparent feedback element)

---

### 5.5. Fill in the Blank

**Type Code**: `fillInTheBlank`

**Description**: Inline input fields within question text (cloze test).

**Data Structure**:
```typescript
{
  type: 'fillInTheBlank',
  parts: QuestionPart[], // Mix of text and input parts
  correctAnswerText: string, // JSON object: { inputId: correctValue }
}

// Special part types:
// - QuestionPartType.sequence: Contains children (inline layout)
// - QuestionPartType.input: Input field with unique `id`
```

**Rendering**:
- **Sequence Layout**: Use flexbox/wrap to flow text and inputs inline
- **Input Fields**:
  - Width: 70px
  - Blue/green background when active
  - Center-aligned text
  - Tap to activate → Shows numeric keyboard
- **Example**: "The answer is ___ and ___"
  - Parts: [text: "The answer is", input: id="input1", text: "and", input: id="input2"]

**Interaction**:
1. User taps any input field → Activates that field (highlighted)
2. User types using keyboard → Updates active field
3. User taps another field or clicks Submit

**Validation**:
```typescript
function validateFillInBlank(
  question: Question,
  userAnswers: Record<string, string> // inputId -> userValue
): boolean {
  const correctAnswers = JSON.parse(question.correctAnswerText || '{}');
  return Object.entries(correctAnswers).every(([id, correct]) => 
    userAnswers[id]?.trim().toLowerCase() === String(correct).toLowerCase()
  );
}
```

---

### 5.6. Four Pics One Word

**Type Code**: `fourPicsOneWord`

**Description**: Guess word from 4 images using jumbled letters.

**Data Structure**:
```typescript
{
  type: 'fourPicsOneWord',
  parts: QuestionPart[], // Image parts (1 or 4 images)
  correctAnswerText: string, // The correct word
  // Generated at runtime:
  // - jumbledLetters: shuffled letters + distractors
  // - currentWordInput: user's letter selections
}
```

**Rendering**:
- **Images**:
  - If 1 image: Large single image (300px height)
  - If 4 images: 2x2 grid (300px total height)
  - Rounded corners, contain fit
- **Answer Slots**:
  - Horizontal row of boxes (one per letter in answer)
  - Empty: Grey background, grey border
  - Filled: Blue background, blue border, show letter
  - Tap filled box → Remove letter back to keyboard
- **Letter Keyboard**:
  - Grid of letter buttons (3-4 columns)
  - Includes correct letters + 2-4 random distractors
  - Tapped letters become hidden (opacity: 0)

**Interaction**:
1. User taps letter from keyboard
2. Letter fills next empty slot (left to right)
3. User can tap filled slot to remove letter (returns to keyboard)
4. User clicks Submit when all slots filled

**Validation**:
```typescript
function validateFourPics(question: Question, userWord: string[]): boolean {
  const answer = question.correctAnswerText.toUpperCase();
  return userWord.join('') === answer;
}
```

**Implementation Notes**:
- Generate jumbled letters on question load: `shuffleArray(answer.split('')) + randomLetters`
- Mark used letters with prefix `#` to hide them visually while preserving position

---

### 5.7. Image Choice

**Type Code**: `imageChoice`

**Description**: MCQ variant optimized for image-based options. Same as MCQ but uses `richOptions` with visual-first layout.

**Data Structure**:
Same as MCQ, but all options are `RichOption` with images.

**Rendering**:
- Same rendering logic as MCQ
- Typically uses grid layout (not vertical)
- Image-first display (larger images, smaller text labels)

**Validation**:
Same as MCQ validation logic.

---

## 6. Question Part Types

Questions are composed of **parts** that can be mixed and matched:

| Part Type | Description | Rendering |
|-----------|-------------|-----------|
| `text` | Plain text or markdown | `<MarkdownBody>` with bold styling |
| `math` | LaTeX math formula | `<Math.tex>` using KaTeX or MathJax |
| `image` | Remote image URL | `<Image>` with loading/error states |
| `svg` | SVG string or URL | `<SvgRenderer>` (inline SVG or remote) |
| `sequence` | Inline container | Flexbox wrap with children |
| `input` | Input field (Fill in Blank) | Text input with unique ID |
| `diagram` | Reserved for future use | Placeholder icon |

**Example Question Parts**:
```typescript
parts: [
  { type: 'text', content: 'Solve for **x**:' },
  { type: 'math', content: 'x^2 + 5x + 6 = 0' },
  { type: 'image', imageUrl: 'https://...', width: 300, height: 200 }
]
```

---

## 7. Common UI Components for Practice

### 7.1. Status Bar
- **Desktop**: Sidebar with session stats
- **Mobile**: Top bar with stage progress
- **Elements**:
  - Current stage (1-4) with visual indicator
  - SmartScore (0-100) with color-coded progress bar
  - Streak counter
  - Questions answered today

### 7.2. Feedback Overlay
- **Correct Answer**:
  - Green background, checkmark icon
  - Praise message ("Correct!", "Great job!")
  - +10 SmartScore animation
- **Incorrect Answer**:
  - Red background, X icon
  - "Sorry, that's incorrect" message
  - Show correct answer
  - SmartScore penalty (varies by current score)
- **Solution View**:
  - Same rich content rendering as question parts
  - "Continue" button to proceed

### 7.3. Audio Control
- Text-to-speech button (speaker icon)
- Reads question text and options
- Toggle play/stop

### 7.4. Numeric Keyboard
- 3-column grid layout
- Keys: 1-9, 0 (bottom center)
- Backspace button (top right)
- Submit button (bottom right)
- Responsive sizing for mobile/tablet

---

## 8. Practice Session Flow

```
1. Load Skill Page → Fetch Questions (by micro_skill_id, adaptive difficulty)
2. Show Question 1 → Render based on type
3. User Interacts → Capture answer
4. User Submits → Validate answer
5. Show Feedback → Correct/Incorrect overlay (2s auto-dismiss or manual)
6. Update SmartScore → Apply algorithm (+10 correct, -X incorrect)
7. Check Stage Progress → If stage complete, show celebration
8. Check Mastery → If SmartScore >= 100, show mastery overlay
9. Load Next Question → Adaptive difficulty based on current score
10. Repeat 2-9
11. User Exits → Save session (score, questions answered, time, target complexity)
```

**Adaptive Difficulty**:
- Target Complexity = Current SmartScore (0-100)
- Fetch questions with `complexity` close to target
- Adjust target based on performance (increase on correct streak, decrease on incorrect)

---


#### Drag & Drop Specifics
- Use `dnd-kit`.
- Create `Droppable` zones for the `dragGroups`.
- Create `Draggable` items for `dragItems`.
- Handle `onDragEnd` to check if item was dropped in the correct group (`item.targetGroupId === group.id`).

### 4.5. Components Checklist
- [ ] **AppHeader**: Logo, User Menu, Daily Stats (pills).
- [ ] **SubjectCard**: Icon + Title + Hover effect.
- [ ] **SmartScoreWidget**: Vertical or horizontal progress bar (0-100).
- [ ] **Question renderers**:
    - `MCQOptions`: Grid of buttons or clickable images.
    - `MathText`: Component to render LaTeX (e.g., `$$ x^2 + y $$`) mixed with standard text.

## 9. Deployment
- **Platform**: Vercel (Recommended for Next.js) or any Node.js host.
- **Environment Variables**:
    - `NEXT_PUBLIC_SUPABASE_URL`
    - `NEXT_PUBLIC_SUPABASE_ANON_KEY`

## 10. Migration Steps
1.  **Initialize Next.js**: `npx create-next-app@latest ixl-web --typescript --tailwind --eslint`.
2.  **Setup Supabase**: Install client and copy types/schema.
3.  **Port Standard UI**: Layout, Navbar, Auth pages.
4.  **Implement Dashboard**: Data fetching for Grades/Subjects.
5.  **Build Practice Engine**: Start with MCQ, then add complex types like Drag & Drop.
6.  **Polish**: Animations, Loading states, Error handling.
