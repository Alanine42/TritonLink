-- Ancient: create tables:
create table if not exists cpqg as (select ct.student_id, c.course_id, c.quarter, c.faculty_name, ct.grade from classes c join classes_taken ct on c.section_id = ct.section_id );
create table if not exists cpg as (select ct.student_id, c.course_id, c.faculty_name, ct.grade from classes c join classes_taken ct on c.section_id = ct.section_id );

-- Update grade in classes_taken -> Update in both cpg and cpqg

-- Create the trigger function
CREATE OR REPLACE FUNCTION update_cpqg_cpg()
  RETURNS TRIGGER AS $$
BEGIN
  -- Update the cpqg table incrementally based on the inserted values in classes_taken
  UPDATE cpqg
  SET grade = NEW.grade
  WHERE cpqg.course_id = (SELECT course_id FROM classes WHERE section_id = NEW.section_id)
    AND cpqg.quarter = (SELECT quarter FROM classes WHERE section_id = NEW.section_id)
    AND cpqg.faculty_name = (SELECT faculty_name FROM classes WHERE section_id = NEW.section_id)
	AND cpqg.student_id = NEW.student_id;
  
  -- Update the cpg table incrementally based on the inserted values in classes_taken
  UPDATE cpg
  SET grade = NEW.grade
  WHERE cpg.course_id = (SELECT course_id FROM classes WHERE section_id = NEW.section_id)
    AND cpg.faculty_name = (SELECT faculty_name FROM classes WHERE section_id = NEW.section_id)
	AND cpg.student_id = NEW.student_id;
	
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger to invoke the function after each insert in classes_taken
CREATE or replace TRIGGER update_cpqg_cpg_trigger
AFTER update ON classes_taken
FOR EACH ROW
EXECUTE FUNCTION update_cpqg_cpg();

-- Inserrt\t
CREATE OR REPLACE FUNCTION insert_cpqg_cpg()
  RETURNS TRIGGER AS $$
BEGIN
  -- Insert a new row into the cpqg table
  INSERT INTO cpqg (course_id, quarter, faculty_name, student_id, grade)
  SELECT course_id, quarter, faculty_name, NEW.student_id, NEW.grade
  FROM classes
  WHERE section_id = NEW.section_id;
  
  -- Insert a new row into the cpg table
  INSERT INTO cpg (course_id, faculty_name, student_id, grade)
  SELECT course_id, faculty_name, NEW.student_id, NEW.grade
  FROM classes
  WHERE section_id = NEW.section_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger to invoke the function after each insert in classes_taken
CREATE or replace TRIGGER insert_cpqg_cpg_trigger
AFTER insert ON classes_taken
FOR EACH ROW
EXECUTE FUNCTION insert_cpqg_cpg();



-- DELETE
-- Create the trigger function
CREATE OR REPLACE FUNCTION delete_cpqg_cpg()
  RETURNS TRIGGER AS $$
BEGIN
  -- Delete the corresponding rows from the cpqg table when a row is deleted from classes_taken
  DELETE FROM cpqg
  WHERE cpqg.course_id = (SELECT course_id FROM classes WHERE section_id = OLD.section_id)
    AND cpqg.quarter = (SELECT quarter FROM classes WHERE section_id = OLD.section_id)
    AND cpqg.faculty_name = (SELECT faculty_name FROM classes WHERE section_id = OLD.section_id)
    AND cpqg.student_id = OLD.student_id;
  
  -- Delete the corresponding rows from the cpg table when a row is deleted from classes_taken
  DELETE FROM cpg
  WHERE cpg.course_id = (SELECT course_id FROM classes WHERE section_id = OLD.section_id)
    AND cpg.faculty_name = (SELECT faculty_name FROM classes WHERE section_id = OLD.section_id)
	AND cpg.student_id = OLD.student_id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger to invoke the function after each delete in classes_taken
CREATE OR REPLACE TRIGGER delete_cpqg_cpg_trigger
AFTER DELETE ON classes_taken
FOR EACH ROW
EXECUTE FUNCTION delete_cpqg_cpg();