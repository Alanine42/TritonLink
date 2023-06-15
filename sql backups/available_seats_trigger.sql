CREATE OR REPLACE FUNCTION update_available_seats()
  RETURNS TRIGGER AS
$$
BEGIN
  -- Check if the section's available_seats is zero or less
  IF (
    SELECT available_seats
    FROM classes
    WHERE section_id = NEW.section_id
  ) <= 0 THEN
    RAISE EXCEPTION 'No available seats for this section';
  ELSE
    -- Decrease the available_seats by one for the corresponding section_id
    UPDATE classes
    SET available_seats = available_seats - 1
    WHERE section_id = NEW.section_id;
  END IF;

  RETURN NEW;
END;
$$
LANGUAGE plpgsql;



CREATE or replace TRIGGER decrease_available_seats_trigger
AFTER INSERT OR UPDATE ON course_enrollment
FOR EACH ROW
WHEN (NEW.enrollment_status = 'enroll')
EXECUTE FUNCTION update_available_seats();
