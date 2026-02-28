# WEXLS Production Readiness Checklist

Status legend:
- `PASS`: implemented and verified
- `PARTIAL`: implemented but needs hardening/verification
- `FAIL`: missing for production

## 1) Platform Health
- [x] App builds successfully in production mode (`next build`) - `PASS`
- [ ] Resolve workspace root warning (multiple lockfiles) - `PARTIAL`

## 2) Auth and Identity
- [x] Login/Register flows implemented - `PASS`
- [x] Signed-in user display on home - `PASS`
- [ ] Enforce canonical `auth_user_id <-> student_id` mapping in all APIs - `PARTIAL`

## 3) Curriculum Data
- [x] Grades/Subjects/Units/Microskills loaded from DB - `PASS`
- [ ] Migration/seed consistency verified across environments - `PARTIAL`

## 4) Practice APIs
- [x] Practice fetch/submit APIs implemented - `PASS`
- [ ] Validate full non-repetition behavior under large session runs - `PARTIAL`

## 5) Question Rendering Coverage
- [x] `mcq` - `PASS`
- [x] `imageChoice` - `PASS`
- [x] `fillInTheBlank` - `PASS`
- [x] `textInput` - `PASS`
- [x] `sorting` - `PASS`
- [x] `dragAndDrop` - `PASS`
- [x] `measure` - `PASS`
- [x] `fourPicsOneWord` - `PASS`
- [x] `gridArithmetic` - `PASS`
- [x] `shadeGrid` - `PASS`
- [x] `butterflyFraction` (custom part) - `PASS`
- [ ] Add strict runtime schema validation by `type` and `part.type` - `PARTIAL`

## 6) Adaptive Engine
- [x] Session lifecycle (`warmup/core/challenge/recovery/done`) - `PASS`
- [x] Mastery/confidence updates - `PASS`
- [x] Recovery path with misconception routing - `PASS`
- [ ] Full psychometric calibration (difficulty/discrimination/slip/guess) - `PARTIAL`
- [ ] Cycle-safe non-repetition guarantees with fallback strategy - `PARTIAL`

## 7) Misconception Pipeline
- [x] Misconception mapping hooks in adaptive submit logic - `PASS`
- [ ] Bank-wide metadata coverage (`adaptive_config`) enforced - `PARTIAL`
- [ ] Monitoring to detect null/invalid misconception writes - `PARTIAL`

## 8) Teacher Analytics
- [x] Analytics screen and APIs implemented - `PASS`
- [ ] Harden date-range/timezone behavior and empty-state diagnostics - `PARTIAL`

## 9) Admin Tooling
- [x] Admin CRUD for curriculum/questions - `PASS`
- [ ] Pre-save JSON validation with actionable error messages - `PARTIAL`
- [ ] Import diagnostics (row-level reason on failure) - `PARTIAL`
- [ ] Keep DB `questions_type_check` and UI type list in sync - `PARTIAL`

## 10) Database and Infra
- [x] Adaptive tables integrated in code (`attempt_events`, `session_state`, `student_skill_state`, `misconception_events`) - `PASS`
- [ ] Replay-test migrations on clean DB - `FAIL`
- [ ] Verify production indexes for selection/analytics paths - `PARTIAL`
- [ ] Enforce API idempotency and retry safety - `PARTIAL`

## 11) Performance and Reliability
- [ ] Add explicit timeout/retry/backoff policy for adaptive APIs - `PARTIAL`
- [ ] Set latency SLO/SLA for next-question selection path (target <150ms) - `PARTIAL`
- [ ] Add telemetry for adaptive errors, retries, and fallbacks - `PARTIAL`

## 12) Security
- [ ] Verify/lock Supabase RLS policies for all learner event tables - `PARTIAL`
- [ ] Ensure answer keys are never leaked in pre-submit payloads - `PARTIAL`

## 13) SEO and Routing
- [x] Basic metadata/robots/sitemap present - `PASS`
- [ ] Final canonical URL strategy for dynamic routes - `PARTIAL`

## 14) Mobile and UX QA
- [x] Major responsive improvements implemented - `PASS`
- [ ] Full regression pass across all custom interactive types - `PARTIAL`

---

## Go-Live Priority Plan (Top 10)
1. Add strict JSON schema validation for question create/import.
2. Enforce required adaptive metadata for adaptive skills (`conceptTags`, misconception mapping).
3. Run migration replay test on an empty database.
4. Audit and add critical DB indexes for adaptive selection and analytics.
5. Finalize non-repetition logic with cycle-completion behavior.
6. Add timeout + retry/backoff policy for adaptive API calls.
7. Harden RLS and auth checks on all write/read paths.
8. Build E2E tests for top question types and adaptive transitions.
9. Add production telemetry (latency/error/fallback dashboards).
10. Freeze supported question types and align DB constraint + renderer + admin UI.

---

## Owner / Status Tracker
| Area | Owner | Status | Notes |
|---|---|---|---|
| Schema validation |  | Not started | Use per-type JSON schema in admin + API |
| Adaptive metadata coverage |  | In progress | Backfill `adaptive_config` for existing bank |
| Migration replay |  | Not started | Mandatory before release |
| Index audit |  | Not started | Validate with real query plans |
| Non-repetition hardening |  | In progress | Session cycle fallback still needs testing |
| Retry/backoff/timeouts |  | Not started | Add shared fetch policy |
| RLS hardening |  | Not started | Verify all event tables |
| E2E suite |  | Not started | Include mobile flows |
| Observability |  | Not started | Track adaptive path latency + failures |
| Type/constraint sync |  | In progress | Prevent unsupported type imports |
