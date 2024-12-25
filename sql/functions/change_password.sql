create or replace function change_password(pw varchar(32), newpw varchar(32), tk varchar(255))
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

	if md5(pw) <> (select password from users where users.login = lgn) then
    	return json_object('result' VALUE 'wrong_password');
	end if;

	update users
	set password = md5(newpw)
	where login = lgn;

	perform logout_everywhere(tk);
    
	return json_object('result' VALUE 'ok');
end;
$$;
