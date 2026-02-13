-- Table for storing user feedback on specific questions
CREATE TABLE IF NOT EXISTS "public"."question_feedback" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    "question_id" uuid,
    "user_id" uuid,
    "feedback" text,
    "created_at" timestamptz DEFAULT now()
);

-- Optional: Foreign key constraints if strict integrity desired
-- ALTER TABLE "public"."question_feedback" ADD CONSTRAINT "fk_question" FOREIGN KEY ("question_id") REFERENCES "public"."questions" ("id");
-- ALTER TABLE "public"."question_feedback" ADD CONSTRAINT "fk_user" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id");
