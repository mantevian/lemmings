create or replace function get_my_login(tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
begin
	select get_login_from_token(tk) into lgn;

	if lgn is null then
		return json_object('result' VALUE 'user_not_found');
	end if;

	return json_object('result' VALUE 'ok', 'login' VALUE lgn);
end;
$$;
