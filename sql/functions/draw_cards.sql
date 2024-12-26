create or replace function draw_cards(gid varchar, lgn varchar, amount integer)
returns bool
language plpgsql
external security invoker
as $$
declare
    did_game integer;
	did_player integer;
	c record;
	p integer;
begin
	select id_deck from games where id_game = gid into did_game;

	if did_game is null then
		return false;
	end if;

	select id_deck from get_player(gid, lgn) into did_player;

	if did_player is null then
		return false;
	end if;

	for c in (
		select id_deck, card
		from deck_cards
		where id_deck = did_game
		order by random()
		limit amount
	) loop
		select coalesce(max(pos), 0) + 1 from deck_cards where id_deck = did_player into p;

		insert into deck_cards (id_deck, card, pos) values (did_player, c.card, p);

		with card_to_delete as (
			select id_deck, card
			from deck_cards
			where id_deck = did_game and card = c.card
			limit 1
		)
		delete from deck_cards
		using card_to_delete
		where
			deck_cards.id_deck = card_to_delete.id_deck
		and
			deck_cards.card = card_to_delete.card;
	end loop;

	return true;
end;
$$;
