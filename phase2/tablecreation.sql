CREATE TABLE actor(
      a_id INTEGER NOT NULL,
      name CHAR(15) NOT NULL,
      PRIMARY KEY(a_id)
);

CREATE TABLE production_company(
      pc_id INTEGER NOT NULL,
      name CHAR(15) NOT NULL,
      address CHAR(30) NOT NULL,
      PRIMARY KEY(pc_id)
);

CREATE TABLE movie(
      m_id INTEGER NOT NULL,
      name CHAR(10) NOT NULL,
      year INTEGER NOT NULL,
      imdb_score FLOAT NOT NULL,
      prod_company INTEGER NOT NULL,
      FOREIGN KEY (prod_company) REFERENCES production_company(pc_id),
      PRIMARY KEY(m_id)
);


CREATE TABLE casting(
      m_id INTEGER NOT NULL,
      a_id INTEGER NOT NULL,
      FOREIGN KEY (m_id) REFERENCES movie(m_id),
      FOREIGN KEY (pc_id) REFERENCES production_company(pc_id),
      PRIMARY KEY(m_id, a_id)
);
