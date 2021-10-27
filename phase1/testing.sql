-- test the code
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
