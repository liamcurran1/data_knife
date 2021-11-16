CREATE OR REPLACE PROCEDURE put_list_field(list_name text, field_name text)
LANGUAGE SQL
AS $$
insert into list_tab(lname, fname) values (list_name, field_name);
$$
