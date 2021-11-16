CREATE OR REPLACE PROCEDURE put_list_desc(list_name text, list_desc text)
LANGUAGE SQL
AS $$
insert into list_desc(lname, description, created) values (list_name, list_desc, now()::timestamp);
$$

