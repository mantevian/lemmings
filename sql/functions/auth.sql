create or replace function auth(lg varchar(32), pw varchar(32), tk varchar(255))
returns json
language plpgsql
external security definer
as $$
begin
	if not check_connection(tk) then
		return json_object('result' VALUE 'not_connected');
	end if;

	if not exists(select * from users where users.login = lg) then
    	return json_object('result' VALUE 'not_registered');
	end if;

	if md5(pw) <> (select password from users where users.login = lg) then
    	return json_object('result' VALUE 'wrong_password');
	end if;

	update connections set login = lg where token = tk;
    
	return json_object('result' VALUE 'ok');
end;
$$;
