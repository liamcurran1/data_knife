CREATE OR REPLACE PROCEDURE public.data_write(_listname text, _dbname text,  _filename text)
 LANGUAGE plpgsql
AS $$
DECLARE
    numrows integer := 0;
    thequery text;
BEGIN
EXECUTE 'SELECT data_extract(''' || _listname  || ''', ''' || _dbname || ''')' INTO thequery;
EXECUTE 'COPY  (' || thequery || ') TO  ''' || _filename || ''' WITH CSV HEADER';
END; 
$$
