import { Game, getCookie } from "../../index.js";
import SceneElement from "../scene.js";

export default class LobbySceneElement extends SceneElement {
	static observedAttributes = ["gid"];

	/** @type {number} */
	roomListRefreshTimer;

	connectedCallback() {
		Game.on("join-room", e => {
			Game.emit("ws", {
				event: "join-room",
				data: {
					"join-code": e.detail.data
				}
			});
		});

		Game.on("open-room-dialog", e => {
			let data = e.detail;
			this.setAttribute("gid", data.id);
			let dialog = this.querySelector("dialog");
			if (data.players) {
				dialog.querySelector("span.player-count").innerHTML = `${data.players.length} / ${data["max_player_count"]}`;
				dialog.querySelector("ul").innerHTML = data.players.map(p => `<li>${p.name}</li>`).join("");
			}
			dialog.showModal();
		});

		Game.on("incoming-game-state", e => {
			if (!this.isOpen()) {
				return;
			}

			let data = e.detail;

			this.setAttribute("gid", data.id);

			let dialog = this.querySelector("dialog");
			dialog.querySelector("span.player-count").innerHTML = `${data.players.length} / ${data["game"]["max_player_count"]}`;
			dialog.querySelector("ul").innerHTML = data.players.map(p => `<li>${p.login}</li>`).join("");
			dialog.showModal();

			if (data["game"]["current_turn_order"]) {
				Game.emit("game-started");
			}
		});

		Game.on("quit-room", () => {
			Game.emit("ws", {
				event: "quit-room",
				data: {
					gid: this.getAttribute("gid")
				}
			});

			this.setAttribute("gid", "");

			let dialog = this.querySelector("dialog");
			dialog.close();
		});

		Game.on("game-started", () => {
			let dialog = this.querySelector("dialog");
			dialog.close();
			Game.goToScene("game");
		});

		Game.on("go-to-account", () => {
			Game.goToScene("account");
		});

		Game.on("go-to-info", () => {
			Game.goToScene("info");
		});

		Game.on("got-my-login", e => {
			this.querySelector("button.profile > span").innerText = e.detail;
		});
	}

	open() {
		Game.emit("ws", {
			event: "get-my-login"
		});

		Game.emit("ws", {
			event: "get-room-list"
		});

		this.roomListRefreshTimer = setInterval(() => {
			Game.emit("ws", {
				event: "get-room-list"
			});

			if (this.getAttribute("gid")) {
				Game.emit("ws", {
					event: "get-game-state",
					data: {
						gid: this.getAttribute("gid")
					}
				});
			}
		}, 1000);
	}

	close() {
		clearInterval(this.roomListRefreshTimer);
	}

	updateList(state) {
		let openRooms = this.querySelector("ul.open-rooms");

		openRooms.innerHTML = state["open_rooms"]?.map(room => /*html*/`
			<li>
				<button>
					<span class="join-code">
						${room["join_code"]}
					</span>
					
					<span class="player-count">
						Игроков: ${room["current_player_count"]} / ${room["player_count"]}
					</span>
					
					<span class="turn-duration">
						Время хода: ${room["turn_duration"]} с
					</span>

					<lm-event on="click" event="join-room" data="${room["join_code"]}" />
				</button>
			</li>
		`).join("") || "";

		let myRooms = this.querySelector("ul.my-rooms");

		myRooms.innerHTML = state["my_rooms"]?.map(room => /*html*/`
			<li>
				<button>
					<span class="join-code">
						${room["join_code"]}
					</span>
					
					<span class="player-count">
						Игроков: ${room["current_player_count"]} / ${room["player_count"]}
					</span>
					
					<span class="turn-duration">
						Время хода: ${room["turn_duration"]} с
					</span>

					<lm-event on="click" event="join-room" data="${room["join_code"]}" />
				</button>
			</li>
		`).join("") || "";
	}
}