create or replace function reset_everything()
returns bool
language plpgsql
external security invoker
as $$
begin
	delete from deck_cards;
	update connections set id_game = null;
	delete from games;
	delete from players;
	delete from decks;
	delete from users;
	delete from connections;

	return true;
end;
$$;
