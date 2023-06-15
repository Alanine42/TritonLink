-- Every concentration in degree Y has a set of courses
-- List those that the student has not yet taken
select m.concentration, f.course_id, c.quarter as next_time_given
from ms_requirement m
join fulfillment f on f.req_id = m.concentration
join classes c on c.course_id = f.course_id
where m.degree = 'CS grad' 
	and (c.quarter = 'Fall 2018' or CAST(SUBSTRING(c.quarter, LENGTH(c.quarter) - 3) AS INT) > 2018)
	and f.course_id not in (
		select co.course_id
		from classes_taken ct
		join classes cl on ct.section_id = cl.section_id
		join courses co on co.course_id = cl.course_id
		where ct.student_id = 'ms'

);


--Next to each course display the next time that this course is given (i.e. 
--the earliest time at which a class of this course is given after SPRING 2018)
-- So Fall 2018, Winter 2019, Spring 2019,...

