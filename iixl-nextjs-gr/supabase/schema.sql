-- Minimal schema for adaptive practice in Supabase

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  microskill_id uuid not null,
  type text not null,
  parts jsonb not null default '[]'::jsonb,
  options jsonb,
  items jsonb,
  drag_items jsonb,
  drop_groups jsonb,
  correct_answer_index int,
  correct_answer_indices jsonb,
  correct_answer_text text,
  solution text,
  difficulty text,
  is_multi_select boolean not null default false,
  is_vertical boolean not null default false,
  show_submit_button boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.student_question_log (
  id bigserial primary key,
  student_id text,
  microskill_id uuid not null,
  question_id uuid not null references public.questions(id) on delete cascade,
  is_correct boolean not null,
  response_ms int not null default 0,
  answer_payload jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_questions_microskill_difficulty
  on public.questions(microskill_id, difficulty);

create index if not exists idx_questions_microskill_sort
  on public.questions(microskill_id, sort_order);

create index if not exists idx_student_question_log_student
  on public.student_question_log(student_id);

create table if not exists public.student_skill_state (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null,
  micro_skill_id uuid not null,
  mastery_score numeric(5,4) not null default 0.2000,
  confidence numeric(5,4) not null default 0.1000,
  difficulty_band text not null default 'easy',
  streak int not null default 0,
  attempts_total int not null default 0,
  correct_total int not null default 0,
  avg_latency_ms int not null default 0,
  last_attempt_at timestamptz,
  next_review_at timestamptz,
  status text not null default 'learning',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(student_id, micro_skill_id)
);

create table if not exists public.session_state (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null,
  micro_skill_id uuid not null,
  phase text not null default 'warmup',
  target_correct_streak int not null default 5,
  current_streak int not null default 0,
  asked_count int not null default 0,
  correct_count int not null default 0,
  active_difficulty text not null default 'easy',
  last_question_id uuid,
  recent_question_ids uuid[] not null default '{}',
  remediation_recent_question_ids uuid[] not null default '{}',
  active_misconception_code text,
  remediation_remaining int not null default 0,
  started_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.attempt_events (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null,
  student_id uuid not null,
  micro_skill_id uuid not null,
  question_id uuid not null references public.questions(id) on delete cascade,
  is_correct boolean not null,
  response_ms int not null,
  attempts_on_question int not null default 1,
  hint_used boolean not null default false,
  answer_payload jsonb,
  correct_payload jsonb,
  selected_difficulty text not null default 'easy',
  concept_tags text[] not null default '{}',
  misconception_code text,
  created_at timestamptz not null default now()
);

create table if not exists public.misconception_events (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null,
  micro_skill_id uuid not null,
  misconception_code text not null,
  severity int not null default 1,
  source_attempt_id uuid references public.attempt_events(id) on delete set null,
  session_id uuid,
  question_id uuid,
  answer_payload jsonb,
  resolved boolean not null default false,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

create index if not exists idx_questions_microskill_difficulty
  on public.questions(microskill_id, difficulty);

create index if not exists idx_attempt_events_student_skill_time
  on public.attempt_events(student_id, micro_skill_id, created_at desc);

create index if not exists idx_attempt_events_session
  on public.attempt_events(session_id, created_at);

create index if not exists idx_session_state_student_skill
  on public.session_state(student_id, micro_skill_id, updated_at desc);

create index if not exists idx_session_state_remediation
  on public.session_state(student_id, micro_skill_id, remediation_remaining, updated_at desc);

create index if not exists idx_misconception_open
  on public.misconception_events(student_id, micro_skill_id, resolved, created_at desc);

create index if not exists idx_misconception_events_session
  on public.misconception_events(session_id, created_at desc);

create index if not exists idx_misconception_events_student_code
  on public.misconception_events(student_id, micro_skill_id, misconception_code, created_at desc);

create or replace function public.submit_and_get_next(
  p_student_id text,
  p_microskill_id uuid,
  p_question_id uuid,
  p_is_correct boolean,
  p_answer_payload jsonb default null
)
returns setof public.questions
language plpgsql
security definer
as $$
declare
  current_sort int := 0;
begin
  select q.sort_order into current_sort
  from public.questions q
  where q.id = p_question_id;

  if current_sort is null then
    current_sort := 0;
  end if;

  return query
  select q.*
  from public.questions q
  where q.microskill_id = p_microskill_id
    and q.sort_order > current_sort
  order by q.sort_order asc
  limit 1;
end;
$$;
