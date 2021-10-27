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
DECLARE
temp_ins_id integer;
temp_batch_adviser record;
BEGIN
    EXECUTE format('CREATE TABLE %I (course_id char(5) NOT NULL, approved char(3));', 'ticket_student_'||NEW.student_id);

    FOR temp_ins_id in (select ins_id from instructor) LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||NEW.student_id, 'instructor_'||temp_ins_id);
    END LOOP;

    FOR temp_batch_adviser in select * from batch_adviser LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||NEW.student_id, 'batch_adviser_'||temp_batch_adviser.ins_id||'_'||temp_batch_adviser.batch);
    END LOOP;
    return NEW;
END;
$$;

CREATE TRIGGER ticket_student
BEFORE INSERT 
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
    return NEW;
END;
$$;

CREATE TRIGGER ticket_instructor
BEFORE INSERT 
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
    EXECUTE format('CREATE TABLE %I (student_id char(11) NOT NULL,course_id char(5) NOT NULL, accepted_by_instructor char(3), accepted_by_batch_advisor char(3));', 'ticket_batch_adviser_'||NEW.ins_id);
    return NEW;
END;
$$;

CREATE TRIGGER ticket_batch_adviser
BEFORE INSERT 
ON batch_adviser
FOR EACH ROW 
EXECUTE PROCEDURE create_batch_adviser_ticket();

-- table of dean tickets
CREATE TABLE tickets_dean (student_id char(11) NOT NULL, course_id char(5) NOT NULL, accepted_by_instructor char(3), accepted_by_batch_adviser char(3), final_decision char(3));

-- STEP2: filling instructor tickets table

-- search all student ticket tables for tickets of courses taught by the instructor
-- add them to instructor ticket table

CREATE OR REPLACE FUNCTION get_tickets_instructor(in_course_id char(5), in_ins_id INTEGER)
RETURNS VOID
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
temp_student_id char(11);
ticket_row record;
BEGIN 
    -- get all student_id
    for temp_student_id in select student_id from Student LOOP
        --access their ticket tables
        for ticket_row in EXECUTE format('SELECT * from %I;', 'ticket_student_'||temp_student_id) LOOP 
            -- check if ticket for the course exists and not already checked
            if ticket_row.course_id = in_course_id AND ticket_row.approved IS NULL then
                --add row in instructor ticket table 
                EXECUTE format('INSERT INTO %I values(%L, %L, %L);', 'ticket_instructor_'||in_ins_id, temp_student_id, ticket_row.course_id, NULL);
            end if;
        END LOOP;
    END LOOP; 
END;
$$;

-- STEP3: filling batch advisor ticket table 

-- search ticket tables of all students in his/her batch 
-- add them into batch_advisor ticket table 

CREATE OR REPLACE FUNCTION get_tickets_batch_adviser(in_ins_id INTEGER)
RETURNS VOID
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
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    -- access batch advisor table to get dept_name and batch 
    select dept_name, batch into temp_dept, temp_batch from batch_adviser where ins_id = in_ins_id;
    -- get all students from student table in the batch and dept
    for temp_student_id in select student_id from Student where dept_name = temp_dept and batch = temp_batch LOOP 
        -- check the ticket tables of all students in the batch 
        for ticket_row in EXECUTE format('SELECT * from %I;', 'ticket_student_'||temp_student_id) LOOP 
            -- check if ticket for the student is not alreday approved
            if ticket_row.approved IS NULL then
                --get instructor for the course 
                EXECUTE format ('select ins_id from %I as CO where CO.course_id = %L;', 'course_offering_'||temp_semester||'_'||temp_year, ticket_row.course_id) into temp_ins_id;
                -- access ticket table of that instructor
                EXECUTE format('select accepted from %I as TI where TI.student_id = %L', 'ticket_instructor_'||temp_ins_id, temp_student_id) into temp_approved;
                --add row in batch ticket table 
                EXECUTE format('INSERT INTO %I values(%L, %L, %L, %L);', 'ticket_batch_adviser_'||in_ins_id, temp_student_id, ticket_row.course_id, temp_approved ,NULL);
            end if;
        END LOOP; 
    END LOOP; 
END;
$$;

-- STEP4: fiiling dean ticket table 

-- all pending tickets from ticket table of all students

CREATE OR REPLACE FUNCTION get_tickets_dean()
RETURNS VOID
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
temp_ins_id INTEGER;
temp_record record;
BEGIN
    -- get all batch advisors
    for temp_ins_id in select ins_id from batch_adviser LOOP 
        -- access all rows of batch advisor ticket tables 
        for temp_record in EXECUTE format('select * from %I;', 'ticket_batch_adviser_'||temp_ins_id) LOOP 
            -- add those rows in dean ticket table 
            INSERT INTO tickets_dean values(temp_record.student_id, temp_record.course_id, temp_record.accepted_by_instructor, temp_record.accepted_by_batch_advisor, NULL);
        END LOOP;
    END LOOP;
END;
$$;

-- STEP5: conveying final decision

-- Procedure to convey final decision to student about ticket approved or not.
-- If approved -- set column of student ticket table to YES else NO.
-- Also add rows in student registration, if the ticket is approved.

CREATE OR REPLACE FUNCTION convey_final_decision()
RETURNS VOID 
LANGUAGE PLPGSQL 
AS $$ 
DECLARE 
dean_ticket_row record;
temp_semester INTEGER;
temp_year INTEGER;
temp_section INTEGER;
temp_ins_id INTEGER;
BEGIN 
    -- get values of current semester and year
    select semester into temp_semester from current_sem_and_year;
    select year into temp_year from current_sem_and_year;
    -- access each row of dean tickets table 
    for dean_ticket_row in select * from tickets_dean LOOP 
        -- if final decision is decided
        if dean_ticket_row.final_decision IS NOT NULL then 
            -- update entry in student ticket table 
            EXECUTE format('UPDATE %I set approved = %L where course_id = %L;', 'ticket_student_'||dean_ticket_row.student_id, dean_ticket_row.final_decision, dean_ticket_row.course_id);
            -- check if decision is approved 
            if dean_ticket_row.final_decision = 'YES' then 
                -- get instructor for the course
                EXECUTE format('select ins_id from %I where course_id = %L;', 'course_offering_'||temp_semester||'_'||temp_year, dean_ticket_row.course_id) into temp_ins_id;
                -- get a section for the course 
                EXECUTE format('select section_id from %I where course_id = %L and ins_id = %L;', 'section_'||temp_semester||'_'||temp_year, dean_ticket_row.course_id, temp_ins_id) into temp_section;
                -- add row in student registration
                EXECUTE format('INSERT INTO %I values(%L, %L, %L);', 'student_registration_'||temp_semester||'_'||temp_year, dean_ticket_row.student_id, dean_ticket_row.course_id, temp_section);
            end if;
        end if;
    END LOOP;
END;
$$;
