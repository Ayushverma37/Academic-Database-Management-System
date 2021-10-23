-- create a trigger on student table that will create a new ticket table for a student when a new student is inserted
-- create a stored procedure get_tickets_instructor which seraches for tickets for the instructor
-- and adds them in instructor tickets table
-- create a stored procedure get_tickets_batch_advisor which searches for tickets for his batch
-- and adds them in batch table for his decision
-- create a stored procedure get_tickets_dean which searches for all tickets in batch advisor tables
-- and adds them in dean tickets table
-- finally dean conveys final confirmation to student


--STEP1: create ticket tables

-- create a trigger on student table that will create a new ticket table for a student when a new student is inserted
-- dean permissions -- run by dean
CREATE OR REPLACE FUNCTION create_student_ticket()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$ 
BEGIN
    EXECUTE format('CREATE TABLE %I (course_id char(5) NOT NULL, approved char(3));', 'ticket_student_'||NEW.student_id);
    return NULL;
END;
$$;

CREATE TRIGGER ticket_student
AFTER INSERT 
ON Student 
FOR EACH ROW 
EXECUTE PROCEDURE create_student_ticket();

-- create trigger on instructor table that will create a new ticket table when a new instructor is added by dean
-- dean permissions -- run by dean
CREATE OR REPLACE FUNCTION create_instructor_ticket()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$ 
BEGIN
    EXECUTE format('CREATE TABLE %I (student_id char(11) NOT NULL, course_id char(5) NOT NULL, accepted char(3));', 'ticket_instructor_'||NEW.ins_id);
    return NULL;
END;
$$;

CREATE TRIGGER ticket_instructor
AFTER INSERT 
ON Instructor 
FOR EACH ROW 
EXECUTE PROCEDURE create_instructor_ticket();

-- create trigger on batch advisor table that will create a new ticket table when a new batch advisor is added by dean
-- dean permissions -- run by dean
CREATE OR REPLACE FUNCTION create_batch_adviser_ticket()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$ 
BEGIN
    EXECUTE format('CREATE TABLE %I (student_id char(5) NOT NULL,course_id char(5) NOT NULL, accepted_by_instructor char(3), accepted_by_batch_advisor char(3));', 'ticket_batch_adviser_'||NEW.ins_id);
    return NULL;
END;
$$;

CREATE TRIGGER ticket_batch_adviser
AFTER INSERT 
ON batch_adviser
FOR EACH ROW 
EXECUTE PROCEDURE create_batch_adviser_ticket();

-- table of dean tickets
CREATE TABLE tickets_dean (student_id char(11) NOT NULL, course_id char(5) NOT NULL, accepted_by_instructor char(3), accepted_by_batch_adviser char(3), final_decision char(3));

-- STEP2: filling instructor tickets table

-- search all student ticket tables for tickets of courses taught by the instructor
-- add them to instructor ticket table

CREATE OR REPLACE FUNCTION get_tickets_instructor(in_course_id char(5), in_ins_id INTEGER)
RETURNS NULL
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
temp_student_id char(11);
ticket_row record;
BEGIN 
    -- get all student_id
    for temp_student_id in select student_id from Students LOOP
        --access their ticket tables
        for ticket_row in EXECUTE format('SELECT * from %I;', 'ticket_student_'||temp_student_id) LOOP 
            -- check if ticket for the course exists and not already checked
            if ticket_row.course_id = in_course_id AND ticket_row.approved = NULL then
                --add row in instructor ticket table 
                EXECUTE format('INSERT INTO %I values(%L, %L, %L);', 'ticket_instructor_'||in_ins_id, temp_student_id, ticket_row.course_id, NULL);
        END LOOP;
    END LOOP; 
    return NULL;
END;
$$;

-- STEP3: filling batch advisor ticket table 

-- search ticket tables of all students in his/her batch 
-- add them into batch_advisor ticket table 

CREATE OR REPLACE FUNCTION get_tickets_batch_advisor(in_ins_id INTEGER)
RETURNS NULL
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
temp_dept varchar(10);
temp_batch integer;
temp_student_id char(11);
ticket_row record;
temp_ins_id INTEGER;
temp_approved char(3);
temp_semester INTEGER;
temp_year INTEGER;
BEGIN
    -- get current semester and year
    SELECT (semester, year) into (temp_semester, temp_year) from current_sem_and_year;
    -- access batch advisor table to get dept_name and batch 
    select dept_name, batch into temp_dept, temp_batch from batch_advisor where ins_id = in_ins_id;
    -- get all students from student table in the batch and dept
    for temp_student_id in select student_id from Students where dept_name = temp_dept and batch = temp_batch LOOP 
        -- check the ticket tables of all students in the batch 
        for ticket_row in EXECUTE format('SELECT * from %I;', 'ticket_student_'||temp_student_id) LOOP 
            -- check if ticket for the student is not alreday approved
            if ticket_row.approved = NULL then
                --get instructor for the course 
                EXECUTE format ('select ins_id into %I from %I as CO where CO.course_id = %L;', temp_ins_id, 'course_offering_'||temp_semester||'_'||temp_year, ticket_row.course_id);
                -- access ticket table of that instructor
                EXECUTE format('select accepted into %I from %I as TI where TI.student_id = %L', temp_approved, 'ticket_instructor_'||temp_ins_id, temp_student_id);
                --add row in batch ticket table 
                EXECUTE format('INSERT INTO %I values(%L, %L, %L %L);', 'ticket_batch_adviser_'||in_ins_id, temp_student_id, ticket_row.course_id, temp_approved ,NULL);
        END LOOP; 
    END LOOP; 
    return NULL;
END;
$$;

-- STEP4: fiiling dean ticket table 

-- all pending tickets from ticket table of all students

CREATE OR REPLACE FUNCTION get_tickets_dean()
RETURNS NULL
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
temp_ins_id INTEGER;
temp_record record;
BEGIN
    -- get all batch advisors
    for temp_ins_id in select ins_id from batch_advisor LOOP 
        -- access all rows of batch advisor ticket tables 
        for temp_record in EXECUTE format('select * from %I;', 'ticket_batch_advisor_'||temp_ins_id) LOOP 
            -- add those rows in dean ticket table 
            INSERT INTO tickets_dean values(temp_record.student_id, temp_record.course_id, temp_record.approved_by_instructor, temp_record.approved_by_batch_advisor, NULL);
        END LOOP;
    END LOOP;
    return NULL;
END;
$$;
