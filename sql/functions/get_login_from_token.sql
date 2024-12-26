create or replace function get_login_from_token(tk varchar(255))
returns varchar
language plpgsql
external security invoker
as $$
declare
	lgn varchar;
begin
	set timezone = 'UTC';

	select login from connections where
		token = tk
	and
		expires > NOW()
	into lgn;

	return lgn;
end;
$$;
