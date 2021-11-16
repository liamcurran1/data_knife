CREATE OR REPLACE PROCEDURE public.build_index()
LANGUAGE plpgsql
AS $$
DECLARE
    mark refcursor;
    rec RECORD;
    nrows integer := 0;
    nproc integer :=0;
BEGIN
  drop table if exists public.dat_index;
  create table public.dat_index (id serial,
       	     		database text,
       	     		schemaref text,
			tableref text,
			numrows integer,
			fieldname text, -- this is the new column
			label text, -- this is a label for the column, can be added later
			PRIMARY KEY (id)
  );
  -- pull out all the PostgreSQL internal information on this database
  insert into public.dat_index (database,schemaref,tableref,fieldname)
       select
	      cast(table_catalog as text),
	      cast(table_schema as text),
	      cast(table_name as text),
       	  cast(column_name as text)
       from information_schema.columns;
  -- remove everything that is not relevant including any columns in tables within the public schema      
  delete from public.dat_index where schemaref = 'information_schema' or schemaref = 'pg_catalog' or schemaref = 'public';
  -- Step through each table listed in dat_index and update the number of rows column
  OPEN mark FOR EXECUTE 'SELECT DISTINCT ON (schemaref,tableref) id, database, schemaref, fieldname, tableref FROM public.dat_index ' ;
  -- Done the main bit, now count haw many rows in each of the tables referenced in dat_index
  <<process_loop>>
  LOOP
    FETCH FROM mark INTO rec;
    -- Funny way of testing whether we've reached the end of rows that can be fetched into rec
    IF NOT FOUND THEN
      EXIT process_loop;
    END IF;
    nproc := nproc + 1;
    -- use EXECUTE INTO command to capture dynamic SQL output and assign it to variable nrows
    EXECUTE 'select count(*) from ' || rec.schemaref || '.' || rec.tableref INTO nrows;
    -- select thisid as "Table Id", nrows as "Number of rows";
    EXECUTE 'update public.dat_index set numrows = $1 where schemaref = $2 and tableref = $3' USING  nrows :: integer,rec.schemaref,rec.tableref;
  END LOOP process_loop;
  CLOSE mark;
  END; 
$$
