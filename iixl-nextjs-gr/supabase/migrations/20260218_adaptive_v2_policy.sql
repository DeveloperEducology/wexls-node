-- Adaptive policy v2 hardening
-- Adds remediation memory on session_state and richer misconception logging.

alter table if exists public.session_state
  add column if not exists remediation_recent_question_ids uuid[] not null default '{}',
  add column if not exists active_misconception_code text,
  add column if not exists remediation_remaining int not null default 0;

create index if not exists idx_session_state_remediation
  on public.session_state(student_id, micro_skill_id, remediation_remaining, updated_at desc);

alter table if exists public.misconception_events
  add column if not exists session_id uuid,
  add column if not exists question_id uuid,
  add column if not exists answer_payload jsonb;

create index if not exists idx_misconception_events_session
  on public.misconception_events(session_id, created_at desc);

create index if not exists idx_misconception_events_student_code
  on public.misconception_events(student_id, micro_skill_id, misconception_code, created_at desc);

