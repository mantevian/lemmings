create or replace function stop_game(gid integer)
returns bool
language plpgsql
external security invoker
as $$
declare
	
begin
	if (select current_turn_started from games where id_game = gid) is null then
		return false;
	end if;

	delete from deck_cards
	where id_deck = (select id_deck from games where id_game = gid);

	delete from deck_cards
	where id_deck in (select id_deck from players where token in (select token from connections where id_game = gid));

	delete from players
	where token in (select token from connections where id_game = gid);

	update connections
	set
		id_game = null
	where
		id_game = gid;

	delete from games
	where id_game = gid;

	return true;
end;
$$;
