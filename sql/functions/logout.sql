create or replace function logout(tk varchar(255))
returns json
language plpgsql
external security definer
as $$
begin
	if (select get_login_from_token(tk)) is null then
		return json_object('result' VALUE 'user_not_found');
	end if;

	update connections set login is null where token = tk;
    
	return json_object('result' VALUE 'ok');
end;
$$;
