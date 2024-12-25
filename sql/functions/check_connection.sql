create or replace function check_connection(tk varchar(255))
returns bool
language plpgsql
external security invoker
as $$
begin
	set timezone = 'UTC';
	
	return length(tk) > 0 and exists(select * from connections where connections.token = tk and connections.expires > NOW());
end;
$$;
