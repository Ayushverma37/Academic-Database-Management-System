-- copy command is used to insert tuples in tables

COPY actor
FROM '/home/keshav/Documents/cs301/phase_2/actor.csv'
DELIMITER ',';

COPY production_company
FROM '/home/keshav/Documents/cs301/phase_2/production.csv'
DELIMITER ',';

COPY movie
FROM '/home/keshav/Documents/cs301/phase_2/movie.csv'
DELIMITER ',';

COPY casting
FROM '/home/keshav/Documents/cs301/phase_2/casting2.csv'
DELIMITER ',';
