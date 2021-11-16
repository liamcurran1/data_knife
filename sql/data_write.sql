CREATE OR REPLACE PROCEDURE public.data_write(_listname text, _filename text)
 LANGUAGE plpgsql
AS $$
DECLARE
    numrows integer := 0;
    thequery text;
BEGIN
EXECUTE 'SELECT data_extract(''' || _listname  ||  ''')' INTO thequery;
EXECUTE 'COPY  (' || thequery || ') TO  ''' || _filename || ''' WITH CSV HEADER';
END; 
$$
