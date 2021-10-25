-- trigger to create new student login
CREATE OR REPLACE FUNCTION create_new_student_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', NEW.student_id, 'abc');
    EXECUTE format('GRANT SELECT ON current_sem_and_year TO %I;' , NEW.student_id);
    EXECUTE format('GRANT SELECT ON timetable_slot_list TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON student TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON instructor TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON batch_adviser TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON Course_Catalog TO %I;', NEW.student_id);
    return NULL;
END;
$$;

CREATE TRIGGER new_student_login
AFTER INSERT 
ON student 
FOR each row 
EXECUTE PROCEDURE create_new_student_login();

-- trigger to create new instructor login 
CREATE OR REPLACE FUNCTION create_new_ins_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', 'instructor_'||NEW.ins_id, 'abc');
    EXECUTE format('GRANT SELECT ON current_sem_and_year TO %I;',  'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON timetable_slot_list TO %I;',  'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON student TO %I;',  'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON instructor TO %I;', 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON batch_adviser TO %I;', 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON Course_Catalog TO %I;',  'instructor_'||NEW.ins_id);
    return NULL;
END;
$$;

CREATE TRIGGER new_ins_login
AFTER INSERT 
ON instructor
FOR each row 
EXECUTE PROCEDURE create_new_ins_login();

-- trigger to create new batch adviser login
CREATE OR REPLACE FUNCTION create_new_ba_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch, 'abc');
    EXECUTE format('GRANT SELECT ON current_sem_and_year TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON timetable_slot_list TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON student TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON instructor TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON batch_adviser TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON Course_Catalog TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    return NULL;
END;
$$;

CREATE TRIGGER new_ba_login
AFTER INSERT 
ON batch_adviser
FOR each row 
EXECUTE PROCEDURE create_new_ba_login();
