/*
# Bible Study Challenge — Admin Platform Schema

## Overview
Creates the full schema for a 6-month Bible-reading challenge admin panel.
This is an admin-only Telegram Mini App for managing readers, tracking their
progress through a daily reading plan, releasing weekly quiz questions, and
viewing a leaderboard ranked by quiz score and reading streaks.

## Tables

### readers
Stores every participant in the challenge.
- id (uuid PK)
- name (text, not null) — display name
- phone (text, nullable) — contact phone
- telegram_id (text, nullable) — Telegram user id when linked
- status (text: 'active' | 'paused' | 'dropped', default 'active')
- current_streak (int, default 0) — consecutive days of completed reading
- longest_streak (int, default 0)
- last_read_date (date, nullable) — last day the reader completed a reading
- created_at (timestamptz)

### reading_schedule
The 182-day (6-month) reading plan. Each row is one day's assignment.
- id (uuid PK)
- day_number (int, not null, unique) — 1..182
- week_number (int, not null) — 1..26
- reading_from (text, not null) — e.g. "Genesis 1"
- reading_to (text, not null) — e.g. "Genesis 3"
- section (text, nullable) — e.g. "Old Testament", "Gospels"
- release_date (date, not null) — calendar date this reading is assigned to

### reading_progress
One row per reader per day — marks a day's reading as done.
- id (uuid PK)
- reader_id (uuid FK → readers, cascade delete)
- schedule_id (uuid FK → reading_schedule, cascade delete)
- completed (boolean, default true)
- completed_at (timestamptz, default now())
- UNIQUE(reader_id, schedule_id)

### quiz_questions
Weekly quiz questions. Each belongs to a week (1..26) and has 4 options.
- id (uuid PK)
- week_number (int, not null) — 1..26
- question_text (text, not null)
- option_a (text, not null)
- option_b (text, not null)
- option_c (text, not null)
- option_d (text, not null)
- correct_option ('a' | 'b' | 'c' | 'd', not null)
- bible_reference (text, nullable) — where the answer comes from
- created_at (timestamptz)

### quiz_responses
A reader's answer to a quiz question.
- id (uuid PK)
- reader_id (uuid FK → readers, cascade delete)
- question_id (uuid FK → quiz_questions, cascade delete)
- selected_option ('a' | 'b' | 'c' | 'd', not null)
- is_correct (boolean, not null)
- answered_at (timestamptz, default now())
- UNIQUE(reader_id, question_id)

## Security
- RLS enabled on every table.
- All policies use TO anon, authenticated (admin-only app, no sign-in screen;
  the anon-key client needs full CRUD on all tables).
*/

-- ── readers ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS readers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  phone text,
  telegram_id text,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','paused','dropped')),
  current_streak integer NOT NULL DEFAULT 0,
  longest_streak integer NOT NULL DEFAULT 0,
  last_read_date date,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE readers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_crud_readers_sel" ON readers;
CREATE POLICY "anon_crud_readers_sel" ON readers FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_crud_readers_ins" ON readers;
CREATE POLICY "anon_crud_readers_ins" ON readers FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_crud_readers_upd" ON readers;
CREATE POLICY "anon_crud_readers_upd" ON readers FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_crud_readers_del" ON readers;
CREATE POLICY "anon_crud_readers_del" ON readers FOR DELETE TO anon, authenticated USING (true);

-- ── reading_schedule ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS reading_schedule (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  day_number integer NOT NULL UNIQUE,
  week_number integer NOT NULL,
  reading_from text NOT NULL,
  reading_to text NOT NULL,
  section text,
  release_date date NOT NULL
);
ALTER TABLE reading_schedule ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_crud_schedule_sel" ON reading_schedule;
CREATE POLICY "anon_crud_schedule_sel" ON reading_schedule FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_crud_schedule_ins" ON reading_schedule;
CREATE POLICY "anon_crud_schedule_ins" ON reading_schedule FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_crud_schedule_upd" ON reading_schedule;
CREATE POLICY "anon_crud_schedule_upd" ON reading_schedule FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_crud_schedule_del" ON reading_schedule;
CREATE POLICY "anon_crud_schedule_del" ON reading_schedule FOR DELETE TO anon, authenticated USING (true);

-- ── reading_progress ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS reading_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reader_id uuid NOT NULL REFERENCES readers(id) ON DELETE CASCADE,
  schedule_id uuid NOT NULL REFERENCES reading_schedule(id) ON DELETE CASCADE,
  completed boolean NOT NULL DEFAULT true,
  completed_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(reader_id, schedule_id)
);
ALTER TABLE reading_progress ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_crud_progress_sel" ON reading_progress;
CREATE POLICY "anon_crud_progress_sel" ON reading_progress FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_crud_progress_ins" ON reading_progress;
CREATE POLICY "anon_crud_progress_ins" ON reading_progress FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_crud_progress_upd" ON reading_progress;
CREATE POLICY "anon_crud_progress_upd" ON reading_progress FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_crud_progress_del" ON reading_progress;
CREATE POLICY "anon_crud_progress_del" ON reading_progress FOR DELETE TO anon, authenticated USING (true);

-- ── quiz_questions ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS quiz_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  week_number integer NOT NULL,
  question_text text NOT NULL,
  option_a text NOT NULL,
  option_b text NOT NULL,
  option_c text NOT NULL,
  option_d text NOT NULL,
  correct_option char(1) NOT NULL CHECK (correct_option IN ('a','b','c','d')),
  bible_reference text,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_crud_questions_sel" ON quiz_questions;
CREATE POLICY "anon_crud_questions_sel" ON quiz_questions FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_crud_questions_ins" ON quiz_questions;
CREATE POLICY "anon_crud_questions_ins" ON quiz_questions FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_crud_questions_upd" ON quiz_questions;
CREATE POLICY "anon_crud_questions_upd" ON quiz_questions FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_crud_questions_del" ON quiz_questions;
CREATE POLICY "anon_crud_questions_del" ON quiz_questions FOR DELETE TO anon, authenticated USING (true);

-- ── quiz_responses ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS quiz_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reader_id uuid NOT NULL REFERENCES readers(id) ON DELETE CASCADE,
  question_id uuid NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
  selected_option char(1) NOT NULL CHECK (selected_option IN ('a','b','c','d')),
  is_correct boolean NOT NULL,
  answered_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(reader_id, question_id)
);
ALTER TABLE quiz_responses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_crud_responses_sel" ON quiz_responses;
CREATE POLICY "anon_crud_responses_sel" ON quiz_responses FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_crud_responses_ins" ON quiz_responses;
CREATE POLICY "anon_crud_responses_ins" ON quiz_responses FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_crud_responses_upd" ON quiz_responses;
CREATE POLICY "anon_crud_responses_upd" ON quiz_responses FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_crud_responses_del" ON quiz_responses;
CREATE POLICY "anon_crud_responses_del" ON quiz_responses FOR DELETE TO anon, authenticated USING (true);

-- ── Indexes ──────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_progress_reader ON reading_progress(reader_id);
CREATE INDEX IF NOT EXISTS idx_progress_schedule ON reading_progress(schedule_id);
CREATE INDEX IF NOT EXISTS idx_questions_week ON quiz_questions(week_number);
CREATE INDEX IF NOT EXISTS idx_responses_reader ON quiz_responses(reader_id);
CREATE INDEX IF NOT EXISTS idx_responses_question ON quiz_responses(question_id);
CREATE INDEX IF NOT EXISTS idx_schedule_week ON reading_schedule(week_number);
CREATE INDEX IF NOT EXISTS idx_readers_status ON readers(status);