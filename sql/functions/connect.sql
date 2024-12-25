create or replace function connect(tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	newtk varchar;
	ex timestamp;
begin
	set timezone = 'UTC';

	if length(tk) = 0 or not exists (select * from connections where connections.token = tk and connections.expires > NOW()) then
		select md5(random()::text) into newtk;
		select NOW() + INTERVAL '1 week' into ex;
		insert into connections (token, expires) values (newtk, ex);
		return json_object('token' VALUE newtk);
	end if;
	
	select NOW() + INTERVAL '1 week' into ex;
	update connections set expires = ex where token = tk;
	return json_object('token' VALUE tk, 'login' VALUE (select login from connections where connections.token = tk));
end;
$$;
