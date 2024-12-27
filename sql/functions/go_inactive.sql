create or replace function go_inactive(tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
begin
	set timezone = 'UTC';

	select get_login_from_token(tk) into lgn;
	if lgn is null then
		return json_object('result' VALUE 'user_not_found');
	end if;

	update connections
	set id_game = null
	where token = tk;

	return json_object('result' VALUE 'ok');
end;
$$;
