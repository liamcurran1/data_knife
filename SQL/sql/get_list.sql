create or replace function get_list (list text)

returns table (var text)
language plpgsql
as $$
begin
return query 
	select
		fname 
	from
		list_tab
	where
		lname=list;
end;$$
