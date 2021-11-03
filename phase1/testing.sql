-- insert instructors into instructor table
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
INSERT INTO student values('2018csb0004', 'Acsb0004', 'Bcsb0004', 'CSE', 2018);
INSERT INTO student values('2018csb0005', 'Acsb0005', 'Bcsb0005', 'CSE', 2018);
INSERT INTO student values('2018eeb0001', 'Aeeb0001', 'Beeb0001', 'EEE', 2018);
INSERT INTO student values('2018eeb0002', 'Aeeb0002', 'Beeb0002', 'EEE', 2018);
INSERT INTO student values('2018eeb0003', 'Aeeb0003', 'Beeb0003', 'EEE', 2018);
INSERT INTO student values('2018eeb0004', 'Aeeb0004', 'Beeb0004', 'EEE', 2018);
INSERT INTO student values('2018eeb0005', 'Aeeb0005', 'Beeb0005', 'EEE', 2018);



-- entry in course catalog
select course_catalog_entry('cs201', 1, 2, 3, 4, 5.5, NULL, NULL, NULL, NULL);
select course_catalog_entry('cs202', 1, 2, 3, 4, 2.5, NULL, NULL, NULL, NULL);
select course_catalog_entry('cs203', 1, 2, 3, 4, 3.5, NULL, NULL, NULL, NULL);
select course_catalog_entry('cs301', 1, 2, 3, 4, 5.5, 'cs201', NULL, NULL, NULL);
select course_catalog_entry('cs302', 1, 2, 3, 4, 5.5, 'cs202', NULL, NULL, NULL);
select course_catalog_entry('cs303', 1, 2, 3, 4, 5.5, 'cs203', NULL, NULL, NULL);
select course_catalog_entry('ge101', 1, 2, 3, 4, 4, NULL, NULL, NULL, NULL);
select course_catalog_entry('ge102', 1, 2, 3, 4, 10, NULL, NULL, NULL, NULL);
select course_catalog_entry('ge103', 1, 2, 3, 4, 4, NULL, NULL, NULL, NULL);


-- update current sem and year 
-- this will create student registration, course offering and section tables
INSERT into current_sem_and_year values(1, 2018);
UPDATE current_sem_and_year set (semester,year) = (1,2019); 

-- insert into timetable_slot_list
-- use procedure timetable slot entry
select Timetable_slot_list_entry('slot1');
select Timetable_slot_list_entry('slot2');
select Timetable_slot_list_entry('slot3');
select Timetable_slot_list_entry('slot4');
select Timetable_slot_list_entry('slot5');
select Timetable_slot_list_entry('slot6');
select Timetable_slot_list_entry('slot7');

-- go to instructor login
select offering_course('cs301', 1, NULL, NULL, 7.5, NULL, 'slot1', TRUE, TRUE, NULL, NULL, NULL, NULL, NULL, NULL);
select entry_section(101, 'cs301', 1, 'room1');

select offering_course('cs302', 2, NULL, NULL, NULL, NULL, 'slot2', TRUE, TRUE, NULL, NULL, NULL, NULL, NULL, NULL);
select entry_section(102, 'cs302', 2, 'room2');

select offering_course('cs303', 3, NULL, NULL, NULL, NULL, 'slot1', TRUE, TRUE, NULL, NULL, NULL, NULL, NULL, NULL);
select entry_section(103, 'cs303', 3, 'room3');

-- student 2018csb0001
-- cgpa: 9.17
insert into trans_2018csb0001 values('cs201', 1, 2018, 10);
insert into trans_2018csb0001 values('cs202', 2, 2018, 9);
insert into trans_2018csb0001 values('cs203', 1, 2018, 8);

-- student 2018csb0002
-- cgpa: 6.48
insert into trans_2018csb0002 values('cs201', 1, 2018, 7);
insert into trans_2018csb0002 values('cs202', 2, 2018, 6);
insert into trans_2018csb0002 values('cs203', 1, 2018, 6);

-- student 2018csb0003
-- cgpa: 3.56
insert into trans_2018csb0003 values('cs201', 1, 2018, 2);
insert into trans_2018csb0003 values('cs202', 2, 2018, 5);
insert into trans_2018csb0003 values('cs203', 1, 2018, 5);

-- student 2018eeb0001
-- cgpa: 8
insert into trans_2018eeb0001 values('cs201', 1, 2018, 8);
insert into trans_2018eeb0001 values('cs202', 2, 2018, 8);
insert into trans_2018eeb0001 values('cs203', 1, 2018, 8);

-- student 2018eeb0002
-- cgpa: 2
insert into trans_2018eeb0002 values('cs201', 1, 2018, 2);
insert into trans_2018eeb0002 values('cs202', 2, 2018, 2);
insert into trans_2018eeb0002 values('cs203', 1, 2018, 2);

-- student 2018eeb0003
-- cgpa: 8.51
insert into trans_2018eeb0003 values('cs201', 1, 2018, 2);
insert into trans_2018eeb0003 values('cs202', 2, 2018, 10);
insert into trans_2018eeb0003 values('cs203', 1, 2018, 10);
insert into trans_2018eeb0003 values('ge101', 1, 2018, 10);
insert into trans_2018eeb0003 values('ge102', 1, 2018, 10);
insert into trans_2018eeb0003 values('ge103', 1, 2018, 10);

-- student 2018eeb0004
-- cgpa: 3.56
insert into trans_2018eeb0004 values('cs201', 1, 2018, 2);
insert into trans_2018eeb0004 values('cs202', 2, 2018, 5);
insert into trans_2018eeb0004 values('cs203', 1, 2018, 5);

-- **********************************************************
-- successful registration
select registration_in_course('2018csb0001', 'cs301', 101);
select registration_in_course('2018csb0001', 'cs302', 102);

-- course in timetable slot already exists
select registration_in_course('2018csb0001', 'cs303', 103);

-- cgpa not fulfilled
select registration_in_course('2018csb0002', 'cs301', 101);
-- successful registration
select registration_in_course('2018csb0002', 'cs302', 102);
select registration_in_course('2018csb0002', 'cs303', 103);

-- successful registration
select registration_in_course('2018eeb0001', 'cs301', 101);
select registration_in_course('2018eeb0001', 'cs302', 102);
-- timetable slot conflict
select registration_in_course('2018eeb0001', 'cs303', 103);

-- unsuccessful registrations
select registration_in_course('2018eeb0002', 'cs301', 101);
select registration_in_course('2018eeb0002', 'cs302', 102);
select registration_in_course('2018eeb0002', 'cs303', 103);

-- pre-requisite not met, cgpa satisfied
select registration_in_course('2018eeb0003', 'cs301', 101);
-- successful
select registration_in_course('2018eeb0003', 'cs302', 102);
select registration_in_course('2018eeb0003', 'cs303', 103);

-- cgpa not fulfilled
select registration_in_course('2018csb0003', 'cs301', 101);
-- successful registration
select registration_in_course('2018csb0003', 'cs302', 102);
-- credit limit exceeded
select registration_in_course('2018csb0003', 'cs303', 103);
-- generate ticket
select generate_ticket('2018csb0003', 'cs303');

select registration_in_course('2018eeb0004', 'cs301', 101);
select registration_in_course('2018eeb0004', 'cs302', 102);
-- credit limit exceeded
select registration_in_course('2018eeb0004', 'cs303', 103);
-- generate ticket
select generate_ticket('2018eeb0004', 'cs303');

-- get tickets for course cs303
select get_tickets_instructor('cs303', 3);
select * from ticket_instructor_3;
update ticket_instructor_3 set accepted = 'YES';

-- get tickets for batch_adviser
select get_tickets_batch_adviser(2);
select * from ticket_batch_adviser_2;
update ticket_batch_adviser_2 set accepted_by_batch_advisor = 'YES';
select * from ticket_batch_adviser_2;

select get_tickets_batch_adviser(7);
select * from ticket_batch_adviser_7;
update ticket_batch_adviser_7 set accepted_by_batch_advisor = 'YES';
select * from ticket_batch_adviser_7;

-- get tickets for dean
select get_tickets_dean();
select * from tickets_dean;
update tickets_dean set final_decision = 'YES' where student_id = '2018csb0003';
update tickets_dean set final_decision = 'NO' where student_id = '2018eeb0004';

select * from student_registration_1_2019;

-- convey final decision for ticket
select convey_final_decision();
select * from student_registration_1_2019;

select * from ticket_student_2018csb0003;
select * from ticket_student_2018eeb0004;

-- add to course grade
select _add_to_course_grade('cs303');
select * from grade_cs303_1_2019;

select get_grades_from_file('/home/keshav/Documents/cs301/phase_1/grade.csv', 'cs303', 3);
select * from grade_cs303_1_2019;

select update_grade_in_trans('cs303');
select * from trans_2018csb0002;
select * from trans_2018csb0003;

select report_generation('2018csb0003');
select * from report_of_2018csb0003_1_2019;

-- course id not elligible
select course_catalog_entry('bm103', 1, 2, 3, 4, 4, NULL, NULL, NULL, 'ge101');
select offering_course('bm103', 5, NULL, NULL, NULL, NULL, 'slot4', TRUE, TRUE, NULL, NULL, NULL, NULL, NULL, NULL);
select entry_section(170, 'bm103', 5, 'room7');
select registration_in_course('2018eeb0003', 'bm103', 170); -- student has already done same type

-- batch and year
select course_catalog_entry('bm102', 1, 2, 3, 4, 4, NULL, NULL, NULL, NULL);
select offering_course('bm102', 5, NULL, NULL, NULL, NULL, 'slot4', FALSE, FALSE, 'CSE', NULL, NULL, 2019, NULL, NULL);
select entry_section(190, 'bm102', 5, 'room9');
select registration_in_course('2019eeb0001', 'bm102', 190); -- course not floated for branch

-- max capacity
select course_catalog_entry('bm101', 1, 2, 3, 4, 4, NULL, NULL, NULL, NULL);
select offering_course('bm101', 5, NULL, NULL, NULL, 1, 'slot3', TRUE, TRUE, NULL, NULL, NULL, NULL, NULL, NULL);
select entry_section(199, 'bm101', 5, 'room5');
select registration_in_course('2019csb0001', 'bm101', 199);
select registration_in_course('2019csb0002', 'bm101', 199); -- course capacity reached

-- same course -- if passed then not again
select offering_course('ge101', 5, NULL, NULL, NULL, NULL, 'slot5', TRUE, TRUE, NULL, NULL, NULL, NULL, NULL, NULL);
select entry_section(110, 'ge101', 5, 'room5');
select registration_in_course('2018eeb0003', 'ge101', 110);  -- already done same course
