
-- classes' meetings currently taking by the student
create or replace view taking as
select c.title, c.course_id, m.day, m.start_time, m.end_time, m.section_id
from course_enrollment ce join meetings m on ce.section_id = m.section_id
join classes c on c.section_id = ce.section_id
where student_id = 'sunshine'  and c.quarter = 'Spring 2018';

-- Other classes offered meetings in the current quarter
create or replace view other as
select c.title, c.course_id, m.day, m.start_time, m.end_time 
from classes c join meetings m on c.section_id = m.section_id
where quarter = 'Spring 2018' and c.section_id not in (select t.section_id from taking t);

-- Join `taking` and `other` on conflicting meetings
select distinct t.course_id, t.title, o.course_id as conflict_course_id, o.title as conflict_title
from taking t join other o 
on t.day = o.day and t.start_time <= o.end_time and o.start_time <= t.end_time
order by o.course_id
;

-- Current quarter : Spring 2018
-- Student: sunshine
-- CSE12 (17) meets at M 10:00-11:00 (LE) and M 11:00-12:00 (DI)
-- conflicts with:
-- CSE30 (16) meets at M 9:30 -11:00 (LE) and Tu 16:00-17:00 (DI)
-- [!] Section 16 might have other meetings that conflicts with 17's meetings,
-- but we only display Section 16's title, course_id ONCE. 

