package server

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{}

func ToStringOrEmpty(input any) string {
	if input == nil {
		return ""
	}
	return input.(string)
}

func ToIntOrNegativeOne(input any) int {
	if input == nil {
		return -1
	}
	res, err := strconv.Atoi(input.(string))
	if err != nil {
		return -1
	}
	return res
}

func ToBool(input any) bool {
	str := ToStringOrEmpty(input)
	return str == "on"
}

func StartHttpServer() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")

		cookie, err := r.Cookie("lemmings-token")
		var token string

		domain := os.Getenv("LEMMINGS_DOMAIN")

		if err != nil {
			token, _ = Connect("")
		} else {
			token, _ = Connect(cookie.Value)
		}

		// if the token was empty/incorrect, we created a new one
		// if the token was correct, this just updates the expiry date
		http.SetCookie(w, &http.Cookie{Name: "lemmings-token", Value: token, MaxAge: 3600 * 24 * 7, Domain: domain, Path: "/"})

		http.ServeFile(w, r, "client/dist/index.html")
	})

	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		cookie, cookieErr := r.Cookie("lemmings-token")

		conn, err := upgrader.Upgrade(w, r, nil)

		if err != nil {
			log.Print("upgrade failed: ", err)
			return
		}

		if cookieErr != nil {
			_ = conn.WriteMessage(websocket.TextMessage, []byte("not_connected"))
			return
		}

		log.Printf("%s", cookie.Value)

		token, login := Connect(cookie.Value)

		log.Printf(token, login)
		if len(login) == 0 {
			err = conn.WriteMessage(websocket.TextMessage, []byte(fmt.Sprintf(`connected {"token":"%s"}`, token)))
		} else {
			err = conn.WriteMessage(websocket.TextMessage, []byte(fmt.Sprintf(`connected {"token":"%s","login":"%s"}`, token, login)))
		}
		if err != nil {
			log.Println("write failed: ", err)
			return
		}

		defer conn.Close()

		for {
			messageType, message, err := conn.ReadMessage()
			if err != nil {
				break
			}

			input := strings.SplitN(string(message), " ", 3)
			token := input[0]
			cmd := input[1]
			msg := input[2]

			if cmd != "get-game-state" && cmd != "get-room-list" {
				log.Printf("request: %s %s", cmd, msg)
			}

			var data map[string]any

			err = json.Unmarshal([]byte(msg), &data)
			if err != nil {
				log.Println("json unmarshal failed: ", err)
				break
			}

			var output string

			switch cmd {
			case "register":
				output = Register(ToStringOrEmpty(data["lgn"]), ToStringOrEmpty(data["pwd"]), token)

			case "get-my-login":
				output = GetMyLogin(token)

			case "auth":
				output = Auth(ToStringOrEmpty(data["lgn"]), ToStringOrEmpty(data["pwd"]), token)

			case "change-password":
				output = ChangePassword(ToStringOrEmpty(data["pwd"]), ToStringOrEmpty(data["newpwd"]), token)

			case "logout":
				output = Logout(token)

			case "logout-everywhere":
				output = LogoutEverywhere(token)

			case "create-room":
				output = CreateRoom(ToIntOrNegativeOne(data["turn-duration"]), ToIntOrNegativeOne(data["player-count"]), token)

			case "get-room-list":
				output = GetRoomList(token)

			case "join-room":
				output = JoinRoom(ToStringOrEmpty(data["join-code"]), token)

			case "quit-room":
				output = QuitRoom(token, ToIntOrNegativeOne(data["gid"]))

			case "get-game-state":
				output = GetGameState(token, ToIntOrNegativeOne(data["gid"]))

			case "next-turn":
				output = NextTurn(token, ToIntOrNegativeOne(data["gid"]))

			case "card-move":
				output = CardMove(token, ToIntOrNegativeOne(data["gid"]), ToStringOrEmpty(data["lemming-1"]), ToStringOrEmpty(data["direction"]))

			case "card-jump":
				output = CardJump(token, ToIntOrNegativeOne(data["gid"]), ToStringOrEmpty(data["lemming-1"]), ToIntOrNegativeOne(data["tile"]))

			case "card-romeo":
				output = CardRomeo(token, ToIntOrNegativeOne(data["gid"]), ToStringOrEmpty(data["lemming-1"]), ToStringOrEmpty(data["lemming-2"]), ToIntOrNegativeOne(data["tile"]))

			case "card-whoosh":
				output = CardWhoosh(token, ToIntOrNegativeOne(data["gid"]), ToStringOrEmpty(data["lemming-1"]), ToStringOrEmpty(data["lemming-2"]))

			case "card-back":
				output = CardBack(token, ToIntOrNegativeOne(data["gid"]), ToStringOrEmpty(data["lemming-1"]))

			case "card-magic":
				output = CardMagic(token, ToIntOrNegativeOne(data["gid"]))

			case "card-crash":
				output = CardCrash(token, ToIntOrNegativeOne(data["gid"]))
			}

			if cmd != "get-game-state" && cmd != "get-room-list" {
				log.Printf("response: %s", output)
			}

			message = []byte(output)
			err = conn.WriteMessage(messageType, message)
			if err != nil {
				log.Println("write failed: ", err)
				break
			}
		}
	})

	http.Handle("/assets/", http.StripPrefix("/assets/", http.FileServer(http.Dir("client/dist/assets"))))

	port := os.Getenv("LEMMINGS_PORT")
	log.Println("Starting server on port " + port)
	err := http.ListenAndServe(":"+port, nil)
	log.Fatal(err)
}
