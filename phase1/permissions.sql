-- trigger to create new student login
CREATE OR REPLACE FUNCTION create_new_student_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', NEW.student_id, 'abc');
    EXECUTE format('GRANT SELECT ON %I TO %I;', current_sem_and_year, NEW.student_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', timetable_slot_list, NEW.student_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', student, NEW.student_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', instructor, NEW.student_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', batch_adviser, NEW.student_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', Course_Catalog, NEW.student_id);
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
    EXECUTE format('GRANT SELECT ON %I TO %I;', current_sem_and_year, 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', timetable_slot_list, 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', student, 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', instructor, 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', batch_adviser, 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', Course_Catalog, 'instructor_'||NEW.ins_id);
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
    EXECUTE format('GRANT SELECT ON %I TO %I;', current_sem_and_year, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON %I TO %I;', timetable_slot_list, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON %I TO %I;', student, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON %I TO %I;', instructor, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON %I TO %I;', batch_adviser, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON %I TO %I;', Course_Catalog, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    return NULL;
END;
$$;

CREATE TRIGGER new_ba_login
AFTER INSERT 
ON batch_adviser
FOR each row 
EXECUTE PROCEDURE create_new_ba_login();
