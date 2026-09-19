ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS book text;
ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS chapter integer;

-- Update existing records if any, then we could optionally make it NOT NULL
-- UPDATE quiz_questions SET book = 'Genesis', chapter = 1 WHERE book IS NULL;

-- We'll just leave them nullable for now to not break anything abruptly, 
-- but our frontend will ensure they are provided for new records.
