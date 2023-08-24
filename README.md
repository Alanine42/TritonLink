## Reports Menu
- Display the classes currently taken by student X
- Display the roster of class Y
- Produce the grade report of student X
- Assist an undergraduate student X in figuring out remaining degree requirements for a bachelors in Y
- Assist a student X in producing his class schedule
- Assist a professor X in scheduling a review session for a section Y offered in the current quarter during the time period from B to E
- Grade distribution for past iterations of a course Y offered by professor X

## Demo
Update student's grade in a class
![grade_update_demo](https://github.com/Alanine42/TritonLink/assets/68050193/e2c0d94d-1358-4796-8ba7-c28db1cf651d)

Add a new section to the course CSE 15L
![add_class_demo](https://github.com/Alanine42/TritonLink/assets/68050193/c0c78832-1a77-4669-82b2-ef2d93564b2c)

Get grade report for several students enrolled in the current quarter
![grade_report](https://github.com/Alanine42/TritonLink/assets/68050193/c00c659e-9725-42a0-946a-c3e0be034903)

## Entity-Relationship/Schema
![ER Diagram](https://github.com/Alanine42/TritonLink/assets/68050193/8202ab2d-6467-459a-b177-4553a8d9af6d)

## Set up
- Download ([PostgreSQL](https://www.postgresql.org/download/)) DBMS
- Apache Tomcat server ([link](https://tomcat.apache.org/))
- Java Server Pages 2.1 ([link](https://www.oracle.com/java/technologies/jspt.html))
- PostgreSQL JDBC Driver ([link](https://jdbc.postgresql.org/))

## Run
- run `deploy.sh` (a script i wrote to build project and start the tomact server)
- open http://localhost:8080/tritonlink/ 

## Entry Forms
Course Entry Form: Provide forms that prompt for course data, one at a time, and appropriately insert them into the database. Course data include prerequisite information.

Class Entry Form: Provide forms that prompt for class data (excluding the list of students who are taking the class) and insert them into the database. Classes will have to refer to courses you have already entered.

Student Entry Form: Forms, again. Exclude information about the classes that the student takes or has taken, the probations he may have received, and his committee info. They will be covered by forms described below.

Faculty Entry Form

Course Enrollment: Provide a form that allows us to insert in the database that student X takes the course Y in the current quarter. If the course has multiple sections prompt for section. If the course is flexible on the number of units prompt the student for the number of units he wants to take.

Classes taken in the Past: Provide a form that allows us to insert in the database that student X took the course Y in quarter Z. If the course has multiple sections prompt for section. Also, ask for the grade G of the student.

Thesis Committee Submission: Provide a form that allows graduate students to submit their thesis committee.

Probation Info Submission

Review Session Info Submission

Degree Requirements’ Info Submission
