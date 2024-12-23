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

func StartHttpServer() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")

		cookie, err := r.Cookie("lemmings-token")
		var token string
		var login string

		domain := os.Getenv("LEMMINGS_DOMAIN")

		if err != nil {
			token, _ = Connect("")
		} else {
			token, login = Connect(cookie.Value)
			http.SetCookie(w, &http.Cookie{Name: "lemmings-login", Value: login, MaxAge: 3600 * 24 * 7, Domain: domain, Path: "/"})
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
				log.Printf("websocket disconnected (token: %s). called quit_room: %s", token, QuitRoom(token))
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
				output = Register(data["lgn"].(string), data["pwd"].(string), token)

			case "auth":
				output = Auth(data["lgn"].(string), data["pwd"].(string), token)

			case "logout":
				output = Logout(token)

			case "logout-everywhere":
				output = LogoutEverywhere(token)

			case "create-room":
				turnDuration, _ := strconv.Atoi(data["turn-duration"].(string))
				playerCount, _ := strconv.Atoi(data["player-count"].(string))
				isPublicStr := data["is-public"].(string)
				isPublic := false
				if isPublicStr == "on" {
					isPublic = true
				}
				output = CreateRoom(turnDuration, playerCount, isPublic, token)

			case "get-room-list":
				output = GetRoomList(token)

			case "join-room":
				output = JoinRoom(data["join-code"].(string), token)

			case "quit-room":
				output = QuitRoom(token)

			case "start-game":
				output = StartGame(token)

			case "get-game-state":
				output = GetGameState(token)

			case "next-turn":
				output = NextTurn(token)

			case "card-move":
				pos, _ := strconv.Atoi(data["n"].(string))
				output = CardMove(token, pos, data["direction"].(string))

			case "card-jump":
				pos, _ := strconv.Atoi(data["n"].(string))
				tile, _ := strconv.Atoi(data["tile"].(string))
				output = CardJump(token, pos, data["lemming-1"].(string), tile)

			case "card-romeo":
				pos, _ := strconv.Atoi(data["n"].(string))
				tile, _ := strconv.Atoi(data["tile"].(string))
				output = CardRomeo(token, pos, data["lemming-1"].(string), data["lemming-2"].(string), tile)

			case "card-whoosh":
				pos, _ := strconv.Atoi(data["n"].(string))
				output = CardWhoosh(token, pos, data["lemming-1"].(string), data["lemming-2"].(string))

			case "card-back":
				pos, _ := strconv.Atoi(data["n"].(string))
				output = CardBack(token, pos, data["lemming-1"].(string))

			case "card-magic":
				pos, _ := strconv.Atoi(data["n"].(string))
				output = CardMagic(token, pos)

			case "card-crash":
				pos, _ := strconv.Atoi(data["n"].(string))
				output = CardCrash(token, pos)
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
