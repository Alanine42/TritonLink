CREATE OR REPLACE FUNCTION check_professor_available()
RETURNS TRIGGER AS $$
DECLARE
  meeting_count INT;
BEGIN
  SELECT COUNT(*)
  INTO meeting_count
  FROM meetings m, meetings m2, classes c
  WHERE c.faculty_name = NEW.faculty_name
    AND m.day = m2.day
    AND m.start_time < m2.end_time and m.end_time > m2.start_time
	and m2.section_id = NEW.section_id and
	m.section_id = c.section_id;

  IF meeting_count > 0 THEN
    RAISE EXCEPTION 'Overlapping meetings detected for the given faculty and section!';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE or replace TRIGGER professor_available_trigger
BEFORE INSERT OR UPDATE ON classes
FOR EACH ROW
EXECUTE FUNCTION check_professor_available();
