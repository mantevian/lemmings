create or replace function next_turn_inner(gid integer)
returns boolean
language plpgsql
external security invoker
as $$
declare
	lgn varchar;
	did integer;
	game_tord integer;
	next_tord integer;
	pc integer;
	c integer;
	count_on_land integer;
begin
	set timezone = 'UTC';

	if (select get_winner(gid)) is not null then
		update games
		set finished = true
		where id_game = gid;
	end if;

	select current_turn_order from games where id_game = gid into game_tord;

	select login
	from players
	where
		id_game = gid
	and
		turn_order = game_tord
	into lgn;

	select
		id_deck
	into
		did
	from get_player(gid, lgn);

	select count(*) from players where id_game = gid into pc;

	select (game_tord % pc + 1) into next_tord;

	update games
	set
		current_turn_order = next_tord,
		current_turn_started = now()
	where id_game = gid;

	select count(*) from deck_cards
	where id_deck = did
	into c;

	perform draw_cards(gid, lgn, 3 - c);

	if not exists(
		select * from connections
		where
			login in (select login from players where id_game = gid and turn_order = next_tord)
		and
			id_game = gid
	) then
		perform next_turn_inner(gid);
	end if;

	return true;
end;
$$;
