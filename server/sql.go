package server

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v4/pgxpool"
)

var pool *pgxpool.Pool

func StartPostgresConnection() {
	var err error

	connString := os.Getenv("POSTGRESQL")

	pool, err = pgxpool.Connect(context.Background(), connString)

	if err == nil {
		log.Println("Connected to Postgres")
	} else {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}

	// defer pool.Close()
}

func sqlFunction(query string, params ...any) (response map[string]any) {
	rows, err := pool.Query(context.Background(), query, params...)

	if err != nil {
		log.Println("err 1 query", err)
		return map[string]any{"result": "error_query"}
	}

	if !rows.Next() {
		log.Println("err 2 no rows", err)
		return map[string]any{"result": "error_no_rows"}
	}

	values, err := rows.Values()
	if err != nil {
		log.Println("err 3 can't parse values", err)
		return map[string]any{"result": "error_cant_parse_values"}
	}

	rows.Close()

	return values[0].(map[string]any)
}

func Connect(token string) (tk string, lg string) {
	res := sqlFunction("select connect($1)", token)
	if res["login"] == nil {
		return fmt.Sprintf("%s", res["token"]), ""
	}
	return fmt.Sprintf("%s", res["token"]), fmt.Sprintf("%s", res["login"])
}

func GetMyLogin(token string) string {
	res := sqlFunction("select get_my_login($1)", token)
	j, _ := json.Marshal(res)
	return "get-my-login " + string(j)
}

func Register(login string, password string, token string) string {
	res := sqlFunction("select register($1, $2, $3)", login, password, token)
	j, _ := json.Marshal(res)
	return "register " + string(j)
}

func Auth(login string, password string, token string) string {
	res := sqlFunction("select auth($1, $2, $3)", login, password, token)
	j, _ := json.Marshal(res)
	return "auth " + string(j)
}

func ChangePassword(password string, newPassword, token string) string {
	res := sqlFunction("select change_password($1, $2, $3)", password, newPassword, token)
	j, _ := json.Marshal(res)
	return "change-password " + string(j)
}

func Logout(token string) string {
	res := sqlFunction("select logout($1)", token)
	j, _ := json.Marshal(res)
	return "logout " + string(j)
}

func LogoutEverywhere(token string) string {
	res := sqlFunction("select logout_everywhere($1)", token)
	j, _ := json.Marshal(res)
	return "logout-everywhere " + string(j)
}

func GetRoomList(token string) string {
	res := sqlFunction("select get_room_list($1)", token)
	j, _ := json.Marshal(res)
	return "get-room-list " + string(j)
}

func CreateRoom(turnDuration int, playerCount int, token string) string {
	res := sqlFunction("select create_room($1, $2, $3)", turnDuration, playerCount, token)
	j, _ := json.Marshal(res)
	return "create-room " + string(j)
}

func JoinRoom(joinCode string, token string) string {
	res := sqlFunction("select join_room($1, $2)", joinCode, token)
	j, _ := json.Marshal(res)
	return "join-room " + string(j)
}

func QuitRoom(token string) string {
	res := sqlFunction("select quit_room($1)", token)
	j, _ := json.Marshal(res)
	return "quit-room " + string(j)
}

func StartGame(token string) string {
	res := sqlFunction("select start_game($1)", token)
	j, _ := json.Marshal(res)
	return "start-game " + string(j)
}

func GetGameState(token string) string {
	res := sqlFunction("select get_game_state($1)", token)
	j, _ := json.Marshal(res)
	return "get-game-state " + string(j)
}

func NextTurn(token string) string {
	res := sqlFunction("select next_turn($1)", token)
	j, _ := json.Marshal(res)
	return "next-turn " + string(j)
}

func CardMove(token string, pos int, direction string) string {
	res := sqlFunction("select card_move($1, $2, $3)", token, pos, direction)
	j, _ := json.Marshal(res)
	return "card-move " + string(j)
}

func CardJump(token string, pos int, color string, tile int) string {
	res := sqlFunction("select card_jump($1, $2, $3, $4)", token, pos, color, tile)
	j, _ := json.Marshal(res)
	return "card-jump " + string(j)
}

func CardRomeo(token string, pos int, color1 string, color2 string, tile int) string {
	res := sqlFunction("select card_romeo($1, $2, $3, $4, $5)", token, pos, color1, color2, tile)
	j, _ := json.Marshal(res)
	return "card-romeo " + string(j)
}

func CardWhoosh(token string, pos int, color1 string, color2 string) string {
	res := sqlFunction("select card_whoosh($1, $2, $3, $4)", token, pos, color1, color2)
	j, _ := json.Marshal(res)
	return "card-whoosh " + string(j)
}

func CardBack(token string, pos int, color string) string {
	res := sqlFunction("select card_back($1, $2, $3)", token, pos, color)
	j, _ := json.Marshal(res)
	return "card-back " + string(j)
}

func CardMagic(token string, pos int) string {
	res := sqlFunction("select card_magic($1, $2)", token, pos)
	j, _ := json.Marshal(res)
	return "card-magic " + string(j)
}

func CardCrash(token string, pos int) string {
	res := sqlFunction("select card_crash($1, $2)", token, pos)
	j, _ := json.Marshal(res)
	return "card-crash " + string(j)
}
