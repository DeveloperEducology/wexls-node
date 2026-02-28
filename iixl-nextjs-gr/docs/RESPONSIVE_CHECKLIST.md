# Responsive QA Checklist

Use this checklist before merging UI changes.

## Viewports to Test
- 360x800 (small phone)
- 390x844 (modern phone)
- 768x1024 (tablet portrait)
- 1024x768 (tablet landscape / small laptop)
- 1366x768 (desktop)

## Core Screens
- `/` home page
- `/skills/[gradeId]/[subjectSlug]`
- `/practice/[microskillId]`
- `/login` and `/register`
- `/teacher/analytics`
- `/admin`

## Pass Criteria
- No horizontal page scroll on any viewport.
- Header/nav remains usable (links not clipped).
- Primary actions are visible without overlap.
- Question cards and answer options stay readable.
- WorkPad opens/closes without clipping controls.
- Tables/charts can be scrolled when needed, without breaking layout.

## Fast Regression Commands
```bash
npm run audit:responsive
npm run lint
```

Notes:
- `audit:responsive` is a static CSS heuristic and may report false positives.
- Treat warnings as prompts for viewport checks, not automatic failures.
