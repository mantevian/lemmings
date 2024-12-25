create or replace function get_login_from_token(tk varchar(255))
returns varchar
language plpgsql
external security invoker
as $$
declare
	lgn varchar;
begin
	set timezone = 'UTC';

	select connections.login from connections where
		connections.token = tk
	and
		connections.expires > NOW()
	into lgn;
    
	if lgn is null then
		return null;
	end if;

	return lgn;
end;
$$;
