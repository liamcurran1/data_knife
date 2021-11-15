CREATE OR REPLACE PROCEDURE create_list_table()
LANGUAGE SQL
AS $$
create table list_tab (
id serial primary key,
lname text not null,
fname text not null
);

create table list_desc(
id serial primary key,
lname text not null,
description text not null,
created timestamp not null);
$$;
