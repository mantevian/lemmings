CREATE TYPE color AS ENUM ('red', 'yellow', 'green', 'blue', 'purple', 'white');
CREATE TYPE card AS ENUM ('move_red', 'move_yellow', 'move_green', 'move_blue', 'move_purple', 'move_white', 'jump', 'romeo', 'whoosh', 'back', 'magic', 'crash');


CREATE TABLE decks (
	id_deck serial primary key
);


CREATE TABLE deck_cards (
	id_deck integer NOT NULL,
	card card NOT NULL,
	pos integer NOT NULL,

	FOREIGN KEY (id_deck) REFERENCES decks (id_deck) ON DELETE CASCADE
);


CREATE TABLE games (
    id_game serial,
    join_code varchar(4) NOT NULL,
    id_deck integer NULL,
    player_count integer NOT NULL,
    turn_duration integer NOT NULL,
    current_turn_order integer NULL,
    current_turn_started timestamp NULL,
    has_hill_crashed bool NOT NULL,

    PRIMARY KEY (id_game),
    UNIQUE (join_code),
    FOREIGN KEY (id_deck) REFERENCES decks (id_deck) ON DELETE CASCADE
);


CREATE TABLE users (
    login varchar(32),
    password varchar(64) NOT NULL,

    PRIMARY KEY (login)
);


CREATE TABLE connections (
    token varchar(255) NOT NULL,
    login varchar(32) NULL,
    expires timestamp NOT NULL,

    PRIMARY KEY (token),
    FOREIGN KEY (login) REFERENCES users (login) ON DELETE CASCADE
);


CREATE TABLE players (
    login varchar(32),
	id_game integer NULL,
    color color NULL,
    turn_order integer NULL,
    tile integer NULL,
    pos integer NULL,
    id_deck integer NULL,
	active boolean NOT NULL,

    UNIQUE (login, id_game),
    FOREIGN KEY (login) REFERENCES users (login) ON DELETE CASCADE,
    FOREIGN KEY (id_deck) REFERENCES decks (id_deck) ON DELETE CASCADE
);
