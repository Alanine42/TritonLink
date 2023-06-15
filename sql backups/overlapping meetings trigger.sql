-- Create a function to check for overlapping time intervals
CREATE OR REPLACE FUNCTION check_meeting_overlap()
  RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM meetings m
    WHERE section_id = NEW.section_id
      AND m.day = NEW.day
      AND m.type <> NEW.type
      AND m.start_time < NEW.end_time
      AND m.end_time > NEW.start_time
  ) THEN
    RAISE EXCEPTION 'The meeting time overlaps with an existing meeting.';
  END IF;

  -- Meetings' time conflicts with any other meeting's time where the faculty_name of these two sections are the same
  IF EXISTS (
    SELECT 1
    FROM classes c, classes c2, meetings m2
    WHERE NEW.section_id = c.section_id
      AND c.faculty_name = c2.faculty_name
	    AND c.quarter = c2.quarter
      AND c2.section_id = m2.section_id
      AND m2.day = NEW.day
      AND m2.start_time < NEW.end_time
      AND m2.end_time > NEW.start_time
	  and new.section_id <> m2.section_id
  ) THEN
    RAISE EXCEPTION 'Meeting time conflicts with the professor''s availability in other sections meetings.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger to invoke the function before each insert
CREATE or REPLACE TRIGGER meeting_overlap_trigger
  BEFORE INSERT OR UPDATE ON meetings
  FOR EACH ROW
  EXECUTE FUNCTION check_meeting_overlap();
