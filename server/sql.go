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

func CreateRoom(turnDuration int, playerCount int, isPublic bool, token string) string {
	res := sqlFunction("select create_room($1, $2, $3, $4)", turnDuration, playerCount, isPublic, token)
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
