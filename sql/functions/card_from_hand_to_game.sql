create or replace function card_from_hand_to_game(did integer, p integer)
returns bool
language plpgsql
external security invoker
as $$
declare
	gid integer;
	did_game integer;
	car card;
	max_pos integer;
begin
	select card from deck_cards where id_deck = did and pos = p into car;

	if car is null then
		return false;
	end if;

	select id_game from connections where token = (select token from players where id_deck = did) into gid;
	select id_deck from games where id_game = gid into did_game;
	
	select 1 into max_pos;
	select max(pos) from deck_cards where id_deck = did_game into max_pos;

	update deck_cards
	set
		id_deck = did_game,
		pos = max_pos + 1
	where
		id_deck = did
	and
		pos = p;

	update deck_cards
	set
		pos = pos - 1
	where
		id_deck = did
	and
		pos > p;

	return true;
end;
$$;
