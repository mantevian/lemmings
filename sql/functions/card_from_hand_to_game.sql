create or replace function card_from_hand_to_game(tk varchar(255), gid integer, c card)
returns bool
language plpgsql
external security invoker
as $$
declare
	lgn varchar;
	p integer;
	did_player integer;
	did_game integer;
	max_pos integer;
begin
	select get_login_from_token(tk) into lgn;

	if not (select is_turn_of(gid, lgn)) then
		return false;
	end if;

	select id_deck from get_player(gid, lgn) into did_player;
	select id_deck from games where id_game = gid into did_game;

	select card_pos
	from deck_cards
	where
		id_deck = did
	and
		card = c
	limit 1
	into p;

	if p is null then
		return false;
	end if;

	select coalesce(max(pos), 1)
	from deck_cards
	where id_deck = did_game
	into max_pos;

	update deck_cards
	set
		id_deck = did_game,
		pos = max_pos + 1
	where
		id_deck = did_player
	and
		pos = p;

	update deck_cards
	set
		pos = pos - 1
	where
		id_deck = did_player
	and
		pos > p;

	return true;
end;
$$;