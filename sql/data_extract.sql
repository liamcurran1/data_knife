CREATE OR REPLACE FUNCTION public.data_extract(_listname text)
 RETURNS text
 LANGUAGE plpgsql
AS $$
DECLARE
    /*
    Variables:
      rec - Pascal like composite structure (RECORD) accessed by property name
      mark - Cursor variable for iterating through the results of the initial query via process_loop
      lasttableref - the name of the table referenced in the previous iteration of process_loop 
      extjoin - used to construct query piece by piece through concatenation
      extcols - used to help control the placement of commas in the query being constructed
      extqry - the final result of the function
      nrows - the number of cases in the current table
    */
    mark refcursor;
    lasttableref text := '';
    rec RECORD;
    extjoin text := '';
    extcols text;
    extqry text;
    nrows integer := 0;
    
BEGIN
  -- It's important to order this query by tableref as we test to see if this changes and by numrows to ensure the maximum number of results
  OPEN mark FOR EXECUTE 'SELECT * FROM (SELECT distinct on (fieldname)  database, schemaref, fieldname, tableref, numrows FROM public.dat_index ' ||
	                'WHERE lower(fieldname) IN (SELECT * FROM get_list(''' || _listname || ''')) order by fieldname, numrows DESC) AS foo ORDER BY numrows DESC,tableref';
  <<process_loop>>
  LOOP
    FETCH FROM mark INTO rec;
    IF NOT FOUND THEN
      EXIT process_loop;
    END IF;
    nrows := nrows + 1;
    -- Check to see if we need to proceed the field name with a comma
    IF nrows <= 1 THEN
      extcols := CONCAT(extcols,quote_ident(rec.fieldname));
    ELSE -- not first row so add comma
      extcols := CONCAT(extcols,', ',quote_ident(rec.fieldname));
    END IF;
    -- Check if the table name has changed from the last one
    IF rec.tableref != lasttableref THEN
      -- Check to see if you need to proceed the table name with JOIN
      IF nrows > 1 THEN
        extjoin := CONCAT(extjoin,' NATURAL LEFT JOIN ',rec.database,'.',rec.schemaref,'.',rec.tableref);
      ELSE
        extjoin := CONCAT(extjoin,rec.database,'.',rec.schemaref,'.',rec.tableref);
      END IF;
      lasttableref := rec.tableref;
    END IF;
   END LOOP process_loop;
  CLOSE mark;
  -- put it all together
  extqry = CONCAT('SELECT ',extcols,' FROM ',extjoin);
  RETURN extqry;
  END; 
$$
