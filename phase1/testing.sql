INSERT INTO instructor values(1, 'Ains1', 'Bins1', 'CSE');
INSERT INTO instructor values(2, 'Ains2', 'Bins2', 'CSE');
INSERT INTO instructor values(3, 'Ains3', 'Bins3', 'CSE');
INSERT INTO instructor values(4, 'Ains4', 'Bins4', 'CSE');
INSERT INTO instructor values(5, 'Ains5', 'Bins5', 'EEE');
INSERT INTO instructor values(6, 'Ains6', 'Bins6', 'EEE');
INSERT INTO instructor values(7, 'Ains7', 'Bins7', 'EEE');
INSERT INTO instructor values(8, 'Ains8', 'Bins8', 'CHE');
INSERT INTO instructor values(9, 'Ains9', 'Bins9', 'CHE');

INSERT INTO batch_adviser values('CSE', 2019, 3);
INSERT INTO batch_adviser values('CSE', 2018, 2);
INSERT INTO batch_adviser values('EEE', 2019, 5);
INSERT INTO batch_adviser values('EEE', 2018, 7);
INSERT INTO batch_adviser values('CHE', 2019, 8);

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

INSERT into current_sem_and_year values(1, 2018);
UPDATE current_sem_and_year set (semester,year) = (1,2019);

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='course_offering_1_2019';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='section_1_2019';

SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='student_registration_1_2019';

select course_catalog_entry('cs101', 1, 2, 3, 4, 5.5, NULL, NULL, NULL, NULL);
select course_catalog_entry('cs102', 1, 2, 3, 4, 4.5, 'cs101', NULL, NULL, NULL);
select course_catalog_entry('cs103', 1, 2, 3, 4, 2.5, NULL, NULL, NULL, 'cs101');
select course_catalog_entry('cs104', 1, 2, 3, 4, 10, NULL, NULL, NULL, NULL);
select course_catalog_entry('cs105', 1, 2, 3, 4, 1.5, 'cs101', NULL, NULL, 'cs104');

INSERT INTO Timetable_slot_list values('ABCDE');
INSERT INTO Timetable_slot_list values('ABXYZ');
INSERT INTO Timetable_slot_list values('AB123');
INSERT INTO Timetable_slot_list values('AB345');

select offering_course('cs101', 3, 4, 5, NULL, NULL, 'ABCDE', TRUE, TRUE, NULL, NULL, NULL, NULL, NULL, NULL);
select entry_section(103, 'cs101', 2, 'room1');

select offering_course('cs102', 3, NULL, NULL, 9.5, 1, 'AB123', FALSE, TRUE, 'CSE', NULL, NULL, NULL, NULL, NULL);
select entry_section(102, 'cs102', 3, 'room8');

select offering_course('cs103', 4, NULL, NULL, NULL, 2, 'ABCDE', TRUE, FALSE, NULL, NULL, NULL, 2018, NULL, NULL);
select entry_section(101, 'cs103', 4, 'room9');

insert into trans_2018csb0001 values('cs101', 1, 2018, 10);
insert into trans_2018csb0002 values('cs101', 1, 2018, 7);
insert into trans_2018csb0002 values('cs105', 2, 2018, 8);

select registration_in_course('2019csb0001', 'cs101', 103);
select registration_in_course('2018csb0001', 'cs102', 102);

select registration_in_course('2018csb0002', 'cs102', 102); -- capacity
update course_offering_1_2019 set maxcapacity = 3 where course_id = 'cs102';
select registration_in_course('2018csb0002', 'cs102', 102); -- cgpa

insert into trans_2018csb0003 values('cs105', 2, 2018, 10);
select registration_in_course('2018csb0003', 'cs102', 102); -- pre-requisite

select registration_in_course('2019csb0002', 'cs103', 101); -- year and branch

insert into trans_2018csb0003 values('cs104', 1, 2018, 9);
select registration_in_course('2018csb0003', 'cs101', 103);
select registration_in_course('2018csb0003', 'cs103', 101); -- timetable slot

select registration_in_course('2018csb0001', 'cs101', 103); -- student has already done same course

select registration_in_course('2018eeb0001', 'cs101', 103); -- credit limit
select generate_ticket('2018eeb0001', 'cs101'); -- generate ticket
select * from ticket_student_2018eeb0001;

select registration_in_course('2018eeb0002', 'cs101', 103);
select generate_ticket('2018eeb0002', 'cs101');

select get_tickets_instructor('cs101', 3);
select get_tickets_instructor('cs101', 2); -- instructor 2 login

update ticket_instructor_2 set accepted = 'YES' where student_id = '2018eeb0001';
update ticket_instructor_2 set accepted = 'NO' where student_id = '2018eeb0002';

select get_tickets_batch_adviser(7);
update ticket_batch_adviser_7 set accepted_by_batch_advisor = 'YES' ;

select get_tickets_dean();
select * from tickets_dean;
update tickets_dean set final_decision = 'YES' where student_id = '2018eeb0001';
update tickets_dean set final_decision = 'NO' where student_id = '2018eeb0002';
select * from tickets_dean;
select * from student_registration_1_2019;
select convey_final_decision();
select * from student_registration_1_2019;

select _add_to_course_grade('cs101');
select * from grade_cs101_1_2019;
select get_grades_from_file('/home/keshav/Documents/cs301/phase_1/grade.csv', 'cs101', 2);
select update_grade_in_trans('cs101');
select * from trans_2019csb0001;
select * from trans_2019csb0002;
select report_generation('2019csb0001');
select * from report_of_2019csb0001_1_2019;
