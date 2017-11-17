DROP TABLE IF EXISTS files;
CREATE TABLE files(filename text);
CREATE OR REPLACE FUNCTION files()
  RETURNS SETOF text AS
$BODY$
BEGIN
  SET client_min_messages TO WARNING;
  TRUNCATE TABLE files;
  CREATE TABLE files(filename text);
  COPY files FROM PROGRAM 'ls /home/postgres9.4/data/base/ -l --time-style="+%Y-%m-%d"';
  RETURN QUERY SELECT * FROM files ORDER BY filename ASC;
END;
$BODY$
  LANGUAGE plpgsql SECURITY DEFINER;