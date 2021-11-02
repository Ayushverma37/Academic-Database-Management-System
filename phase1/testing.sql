-- remove the database
drop database dbf;

-- remove earlier users
drop role "2019csb0001";
drop role "2019csb0002";
drop role "2019csb0003";
drop role "2019csb0004";
drop role "2019csb0005";
drop role "2019eeb0001";
drop role "2019eeb0002";
drop role "2019eeb0003";
drop role "2019eeb0004";
drop role "2019chb0001";
drop role "2019chb0002";
drop role "2019chb0003";
drop role "2018csb0001";
drop role "2018csb0002";
drop role "2018csb0003";
drop role "2018eeb0001";
drop role "2018eeb0002";
drop role "2018eeb0003";
drop role instructor_1;
drop role instructor_2;
drop role instructor_3;
drop role instructor_4;
drop role instructor_5;
drop role instructor_6;
drop role instructor_7;
drop role instructor_8;
drop role instructor_9;
drop role batch_adviser_2_2018;
drop role batch_adviser_3_2019;
drop role batch_adviser_5_2019;
drop role batch_adviser_7_2018;
drop role batch_adviser_8_2019;

-- create new database 
create database dbf;

-- enter the database as dean
psql -d dbf -U postgres -W

-- paste all code in database from total_code.sql

-- display created tables
\dt 
/*
                List of relations
 Schema |         Name         | Type  |  Owner   
--------+----------------------+-------+----------
 public | batch_adviser        | table | postgres
 public | course_catalog       | table | postgres
 public | current_sem_and_year | table | postgres
 public | instructor           | table | postgres
 public | student              | table | postgres
 public | tickets_dean         | table | postgres
 public | timetable_slot_list  | table | postgres
(7 rows)
*/

-- dean fills instructor, student and batch adviser tables

-- insert instructor into instructor table
INSERT INTO instructor values(1, 'Ains1', 'Bins1', 'CSE');
INSERT INTO instructor values(2, 'Ains2', 'Bins2', 'CSE');
INSERT INTO instructor values(3, 'Ains3', 'Bins3', 'CSE');
INSERT INTO instructor values(4, 'Ains4', 'Bins4', 'CSE');
INSERT INTO instructor values(5, 'Ains5', 'Bins5', 'EEE');
INSERT INTO instructor values(6, 'Ains6', 'Bins6', 'EEE');
INSERT INTO instructor values(7, 'Ains7', 'Bins7', 'EEE');
INSERT INTO instructor values(8, 'Ains8', 'Bins8', 'CHE');
INSERT INTO instructor values(9, 'Ains9', 'Bins9', 'CHE');

-- insert batch advisers into batch adviser table
INSERT INTO batch_adviser values('CSE', 2019, 3);
INSERT INTO batch_adviser values('CSE', 2018, 2);
INSERT INTO batch_adviser values('EEE', 2019, 5);
INSERT INTO batch_adviser values('EEE', 2018, 7);
INSERT INTO batch_adviser values('CHE', 2019, 8);

-- insert student into student table
INSERT INTO student values('2019csb0001', 'Acsb0001', 'Bcsb0001', 'CSE', 2019);
INSERT INTO student values('2019csb0002', 'Acsb0002', 'Bcsb0002', 'CSE', 2019);
INSERT INTO student values('2019csb0003', 'Acsb0003', 'Bcsb0003', 'CSE', 2019);
INSERT INTO student values('2019csb0004', 'Acsb0004', 'Bcsb0004', 'CSE', 2019);
INSERT INTO student values('2019csb0005', 'Acsb0005', 'Bcsb0005', 'CSE', 2019);
INSERT INTO student values('2019eeb0001', 'Aeeb0001', 'Beeb0001', 'EEE', 2019);
INSERT INTO student values('2019eeb0002', 'Aeeb0002', 'Beeb0002', 'EEE', 2019);
INSERT INTO student values('2019eeb0003', 'Aeeb0003', 'Beeb0003', 'EEE', 2019);
INSERT INTO student values('2019eeb0004', 'Aeeb0004', 'Beeb0004', 'EEE', 2019);
INSERT INTO student values('2019chb0001', 'Achb0001', 'Bchb0001', 'CHE', 2019);
INSERT INTO student values('2019chb0002', 'Achb0003', 'Bchb0002', 'CHE', 2019);
INSERT INTO student values('2019chb0003', 'Achb0003', 'Bchb0003', 'CHE', 2019);
INSERT INTO student values('2018csb0001', 'Acsb0001', 'Bcsb0001', 'CSE', 2018);
INSERT INTO student values('2018csb0002', 'Acsb0002', 'Bcsb0002', 'CSE', 2018);
INSERT INTO student values('2018csb0003', 'Acsb0003', 'Bcsb0003', 'CSE', 2018);
INSERT INTO student values('2018eeb0001', 'Aeeb0001', 'Beeb0001', 'EEE', 2018);
INSERT INTO student values('2018eeb0002', 'Aeeb0002', 'Beeb0002', 'EEE', 2018);
INSERT INTO student values('2018eeb0003', 'Aeeb0003', 'Beeb0003', 'EEE', 2018);

-- display created users
\du 

-- check priviledges granted on different tables to users
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='current_sem_and_year';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='student';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='instructor';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='batch_adviser';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='course_catalog';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='timetable_slot_list';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='ticket_batch_adviser_2';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='ticket_batch_adviser_3';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='ticket_instructor_2';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='ticket_instructor_7';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='ticket_student_2018csb0001';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='ticket_student_2018csb0002';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='ticket_student_2018csb0003';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='ticket_dean';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='trans_2018csb0001';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='trans_2018csb0002';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='trans_2018csb0003';

-- update current sem and year 
-- this will create student registration, course offering and section tables
INSERT into current_sem_and_year values(1, 2018);
UPDATE current_sem_and_year set (semester,year) = (1,2019); 

-- check permissions on semester dependent tables
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='course_offering_1_2019';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='section_1_2019';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='student_registration_1_2019';

-- insert courses into course catalog 
-- use procedure course_catalog_entry
select course_catalog_entry('cs101', 1, 2, 3, 4, 5.5, NULL, NULL, NULL, NULL);
select course_catalog_entry('cs102', 1, 2, 3, 4, 4.5, 'cs101', NULL, NULL, NULL);
select course_catalog_entry('cs103', 1, 2, 3, 4, 2.5, NULL, NULL, NULL, 'cs101');
select course_catalog_entry('cs104', 1, 2, 3, 4, 10, NULL, NULL, NULL, NULL);
select course_catalog_entry('cs105', 1, 2, 3, 4, 1.5, 'cs101', NULL, NULL, 'cs104');
select course_catalog_entry('ge101', 2, 3, 4, 5, 3.5, NULL, NULL, NULL, NULL);
select course_catalog_entry('ge102', 2, 3, 4, 5, 1.5, NULL, NULL, NULL, NULL);
select course_catalog_entry('ge103', 2, 3, 4, 5, 2.5, NULL, NULL, NULL, NULL);
select course_catalog_entry('ge104', 2, 3, 4, 5, 4.5, NULL, NULL, NULL, NULL);

-- display courses in catalog
select * from course_catalog;

-- insert into timetable_slot_list
-- use procedure timetable slot entry
select Timetable_slot_list_entry('ABCDE');
select Timetable_slot_list_entry('ABXYZ');
select Timetable_slot_list_entry('AB123');
select Timetable_slot_list_entry('AB345');

-- display contents of timetable slot entry
select * from timetable_slot_list;

-- offering a course
-- enter a instructor login -- instructor 2
psql -d dbf -U instructor_2 -W

-- try an invalid offering attempt
select offering_course('cs101', 3, 4, 5, NULL, NULL, 'ABCDE', TRUE, TRUE, NULL, NULL, NULL, NULL, NULL, NULL);
/*ERROR:  Invalid user attempting to offer course
CONTEXT:  PL/pgSQL function offering_course(character,integer,integer,integer,numeric,integer,character varying,boolean,boolean,character,character,character,integer,integer,integer) line 13 at RAISE*/

-- offering a course
-- attributes: no cgpa criterion, no max capacity, open for all departments and year
select offering_course('cs101', 2, 4, 5, NULL, NULL, 'ABCDE', TRUE, TRUE, NULL, NULL, NULL, NULL, NULL, NULL);
-- enter section for the course
select entry_section(103, 'cs101', 2, 'room1');

-- enter a different instructor login -- instructor 3
psql -d dbf -U instructor_2 -W
-- offer a course
-- attrinutes: 9.5 cgpa, capacity is 1, open for only CSE department, all year
select offering_course('cs102', 3, NULL, NULL, 9.5, 1, 'AB123', FALSE, TRUE, 'CSE', NULL, NULL, NULL, NULL, NULL);
select entry_section(102, 'cs102', 3, 'room8');

-- enter a different instructor login -- instructor 4
psql -d dbf -U instructor_4 -W
-- offer a course
-- attributes: capacity is 2, open all for branches, but only 2018 year
select offering_course('cs103', 4, NULL, NULL, NULL, 2, 'ABCDE', TRUE, FALSE, NULL, NULL, NULL, 2018, NULL, NULL);
select entry_section(101, 'cs103', 4, 'room9');

-- display course offering and section tables
select * from course_offering_1_2019;
select * from section_1_2019;

-- insert into trans table for checking purposes
-- actually insertion will happen when dean will call procedure update grade in trans
insert into trans_2018csb0001 values('cs101', 1, 2018, 10);
insert into trans_2018csb0002 values('cs101', 1, 2018, 7);
insert into trans_2018csb0002 values('cs105', 2, 2018, 8);

-- display the trans tables
select * from trans_2018csb0001;
select * from trans_2018csb0002;

-- student registers in a course
-- enter a student login 
psql -d dbf -U 2019csb0001 -W
-- try invalid registration attemp -- due to invalid user
select registration_in_course('2019csb0002', 'cs101', 103);
/*ERROR:  Invalid user attempting to register in course
CONTEXT:  PL/pgSQL function a_check_valid_user() line 9 at RAISE
SQL statement "INSERT INTO student_registration_1_2019 values('2019csb0002', 'cs101', '103');"
PL/pgSQL function registration_in_course(character,character,integer) line 11 at EXECUTE*/
-- try invalid registration -- invalid section entered
select registration_in_course('2019csb0001', 'cs101', 101);
-- display student registration table
select * from student_registration_1_2019;

-- successful registration
select registration_in_course('2019csb0001', 'cs101', 103);
select * from student_registration_1_2019;

-- change user to 2018csb0001
psql -d dbf -U 2018csb0001 -W
select registration_in_course('2018csb0001', 'cs102', 102);
select * from student_registration_1_2019;

-- capacity for a course is full
-- capacity of cs102 is 1
-- change user to 2018csb0002
select registration_in_course('2018csb0002', 'cs102', 102); -- capacity
/*ERROR:  Course Capacity has already been reached for cs102 course
CONTEXT:  PL/pgSQL function _check_capacity() line 14 at RAISE
SQL statement "INSERT INTO student_registration_1_2019 values('2018csb0002', 'cs102', '102');"
PL/pgSQL function registration_in_course(character,character,integer) line 11 at EXECUTE
*/

-- cgpa criterion is not met
update course_offering_1_2019 set maxcapacity = 3 where course_id = 'cs102';
select registration_in_course('2018csb0002', 'cs102', 102); -- cgpa
/*ERROR:  cgpa of Student is less than cgpa criteria for this course
CONTEXT:  PL/pgSQL function _check_cgpa() line 16 at RAISE
SQL statement "INSERT INTO student_registration_1_2019 values('2018csb0002', 'cs102', '102');"
PL/pgSQL function registration_in_course(character,character,integer) line 11 at EXECUTE
dbf=> 
*/

-- pre-requisite for a course not fulfilled
insert into trans_2018csb0003 values('cs105', 2, 2018, 10);
-- change user
select registration_in_course('2018csb0003', 'cs102', 102); -- pre-requisite
/*ERROR:  pre-requisite cs101 not met by student
CONTEXT:  PL/pgSQL function _check_prerequisites() line 11 at RAISE
SQL statement "INSERT INTO student_registration_1_2019 values('2018csb0003', 'cs102', '102');"
PL/pgSQL function registration_in_course(character,character,integer) line 11 at EXECUTE
dbf=> 
*/

-- year and branch not elligible
-- change user
select registration_in_course('2019csb0002', 'cs103', 101); -- year and branch
/*ERROR:  Course not floated for this year
CONTEXT:  PL/pgSQL function _check_batchandyear() line 39 at RAISE
SQL statement "INSERT INTO student_registration_1_2019 values('2019csb0002', 'cs103', '101');"
PL/pgSQL function registration_in_course(character,character,integer) line 11 at EXECUTE*/


-- courses in same timetable slot
insert into trans_2018csb0003 values('cs104', 1, 2018, 9);
select registration_in_course('2018csb0003', 'cs101', 103);
select registration_in_course('2018csb0003', 'cs103', 101); -- timetable slot
/*ERROR:  INSERTION FAILED: Course in timetable slot already exists
CONTEXT:  PL/pgSQL function check_course_in_timetable_slot() line 18 at RAISE
SQL statement "INSERT INTO student_registration_1_2019 values('2018csb0003', 'cs103', '101');"
PL/pgSQL function registration_in_course(character,character,integer) line 11 at EXECUTE
*/

-- what if student registers in a course he/she has already passed
select registration_in_course('2018csb0001', 'cs101', 103); -- student has already done same course
/*ERROR:  Student has already done same course
CONTEXT:  PL/pgSQL function _check_course_id_not_elligible() line 7 at RAISE
SQL statement "INSERT INTO student_registration_1_2019 values('2018csb0001', 'cs101', '103');"
PL/pgSQL function registration_in_course(character,character,integer) line 11 at EXECUTE
dbf=> 
*/

-- credit limit checking 
-- insert into trans
insert into trans_2018eeb0001 values('ge102', 1, 2018, 10);
select registration_in_course('2018eeb0001', 'cs101', 103); -- credit limit
/*ERROR:  Credit limit exceeded
CONTEXT:  PL/pgSQL function z_check_credit_limit() line 23 at RAISE
SQL statement "INSERT INTO student_registration_1_2019 values('2018eeb0001', 'cs101', '103');"
PL/pgSQL function registration_in_course(character,character,integer) line 11 at EXECUTE
*/
select generate_ticket('2018eeb0001', 'cs101'); -- generate ticket
select * from ticket_student_2018eeb0001;

select registration_in_course('2018eeb0002', 'cs101', 103);
select generate_ticket('2018eeb0002', 'cs101');
select * from ticket_student_2018eeb0002;

-- get tickets for instructor
-- use instructor_2 login
select get_tickets_instructor('cs101', 3); -- invalid ins_id
select get_tickets_instructor('cs101', 2); -- instructor 2 login
select * from ticket_instructor_2;

-- instructor conveys the decision
update ticket_instructor_2 set accepted = 'YES' where student_id = '2018eeb0001';
update ticket_instructor_2 set accepted = 'NO' where student_id = '2018eeb0002';

-- get tickets for batch adviser
-- go to batch_advisor login
psql -d dbf -U batch_adviser_7_2018 -W
-- a batch adviser cannot access another batch adviser's table
select get_tickets_batch_adviser(7);
select * from ticket_batch_adviser_7;
update ticket_batch_adviser_7 set accepted_by_batch_advisor = 'YES' ;

-- get tickets for dean
select get_tickets_dean();
select * from tickets_dean;
update tickets_dean set final_decision = 'YES' where student_id = '2018eeb0001';
update tickets_dean set final_decision = 'NO' where student_id = '2018eeb0002';
select * from tickets_dean;
select * from student_registration_1_2019;

-- convey final decision of dean to student ticket table, also adding to student registration
select convey_final_decision();
select * from student_registration_1_2019;
select * from ticket_student_2018eeb0001;
select * from ticket_student_2018eeb0002;

-- to get all students registered in a course
select _add_to_course_grade('cs101');
select * from grade_cs101_1_2019;

-- assign grades from csv file
select get_grades_from_file('/home/keshav/Documents/cs301/phase_1/grade.csv', 'cs101', 2);

-- update grades assigned by instructors into trans student table
select update_grade_in_trans('cs101');
-- change user
psql -d dbf -U 2019csb0001 -W
select * from trans_2019csb0001;

-- report generation
select * from trans_2019csb0001;
select * from trans_2019csb0002;
select report_generation('2019csb0001');
select * from report_of_2019csb0001_1_2019;
