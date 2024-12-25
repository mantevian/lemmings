create or replace function register(lg varchar(32), pw varchar(32), tk varchar(255))
returns json
language plpgsql
external security definer
as $$
begin
	if not check_connection(tk) then
		return json_object('result' VALUE 'not_connected');
	end if;

	if exists(select * from users where users.login = lg) then
    	return json_object('result' VALUE 'user_already_exists');
	end if;
	 
	if length(pw) < 4 then
    	return json_object('result' VALUE 'short_password');
	end if;
    
	insert into users (login, password) values (lg, md5(pw));
	update connections set login = lg where token = tk;

	return json_object('result' VALUE 'ok');
end;
$$;
