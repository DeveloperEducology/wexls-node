-- The app is requesting questions for skill ID: b74172ec-421b-4901-b1a6-388d3db61f87
-- But the data in the database (as seen in the JSON) has ID: 2c063523-e8e6-4505-893d-75b5d65a05de
-- This script updates the questions to match the Skill ID the app is using.

UPDATE questions
SET micro_skill_id = 'b74172ec-421b-4901-b1a6-388d3db61f87'
WHERE micro_skill_id = '2c063523-e8e6-4505-893d-75b5d65a05de';
