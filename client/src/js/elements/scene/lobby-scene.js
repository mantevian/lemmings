import { Game, getCookie } from "../../index.js";
import SceneElement from "../scene.js";

export default class LobbySceneElement extends SceneElement {
	static observedAttributes = [];

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
			let dialog = this.querySelector("dialog");
			dialog.querySelector("span.player-count").innerHTML = `${data.logins.length} / ${data["max_player_count"]}`;
			dialog.querySelector("ul").innerHTML = data.logins.map(p => `<li>${p.name}</li>`).join("");
			dialog.showModal();
		});

		Game.on("incoming-game-state", e => {
			if (!this.isOpen()) {
				return;
			}

			let data = e.detail;
			let dialog = this.querySelector("dialog");
			dialog.querySelector("span.player-count").innerHTML = `${data.logins.length} / ${data["game"]["max_player_count"]}`;
			dialog.querySelector("ul").innerHTML = data.logins.map(p => `<li>${p}</li>`).join("");
			dialog.showModal();

			if (data["game"]["current_turn_order"]) {
				Game.emit("game-started");
			}
		});

		Game.on("quit-room", () => {
			Game.emit("ws", {
				event: "quit-room"
			});

			let dialog = this.querySelector("dialog");
			dialog.close();
		});

		Game.on("start-game", () => {
			Game.emit("ws", {
				event: "start-game"
			});
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
		Game.emit("ws", { event: "get-my-login" });

		Game.emit("ws", { event: "get-room-list" });

		this.roomListRefreshTimer = setInterval(() => {
			Game.emit("ws", { event: "get-room-list" });
			Game.emit("ws", { event: "get-game-state" });
		}, 1000);
	}

	close() {
		clearInterval(this.roomListRefreshTimer);
	}

	updateList(state) {
		let ul = this.querySelector("ul");

		ul.innerHTML = state["rooms"]?.map(room => /*html*/`
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