-- this file contains indexes to be implemented

CREATE INDEX actor_id_index ON actor USING btree (a_id);

CREATE INDEX movie_id_index ON movie USING btree (m_id);

CREATE INDEX movie_imdb_index ON movie USING btree (imdb_score);

CREATE INDEX movie_year_index ON movie USING btree (year);

CREATE INDEX casting_m_id_index ON casting USING btree (m_id);

CREATE INDEX casting_a_id_index ON casting USING btree (a_id);

CREATE INDEX movie_pc_id_index ON movie USING btree (prod_company);
