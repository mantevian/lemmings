import { Game } from "../../index.js";
import SceneElement from "../scene.js";

export default class GameSceneElement extends SceneElement {
	static observedAttributes = ["has-hill-crashed", "hill-crash-finished", "gid"];

	/** @type {number} */
	timer;

	/** @type {string[]} */
	hand = [];

	/** @type {string[]} */
	lemmings = [];

	finished = false;

	connectedCallback() {
		Game.on("game-started", () => {
			this.tick();
			this.timer = setInterval(this.tick.bind(this), 1000);

			this.removeAttribute("has-hill-crashed");
			this.removeAttribute("hill-crash-finished");

			this.querySelector("li[data-type='hill']").classList.remove("crashing", "crashed");
			
			this.hand = [];
			this.lemmings = [];
			this.finished = false;
		});

		Game.on("incoming-game-state", e => {
			if (!this.isOpen() || this.finished) {
				return;
			}

			let data = e.detail;
	
			this.setAttribute("gid", data.id);

			let deckElement = this.querySelector("#deck");

			let len1 = this.hand?.length || 0;
			let len2 = data.hand?.length || 0;

			let deckChanged = false;

			if (len1 != len2) {
				deckChanged = true;
			} else {
				for (let i = 0; i < len1; i++) {
					if (this.hand[i] != data.hand[i]) {
						deckChanged = true;
					}
				}
			}

			if (deckChanged) {
				deckElement.replaceChildren([]);

				for (let i = 0; i < len2; i++) {
					deckElement.innerHTML += `<li><lm-card type="${data.hand[i]}" n="${i}" /></li>`;
				}
			}

			this.hand = data.hand || [];

			let lemmingsContainer = this.querySelector("#lemmings");
			if (lemmingsContainer.childElementCount == 0) {
				for (let lemming of data.lemmings) {
					lemmingsContainer.innerHTML += `<lm-lemming color="${lemming.color}" tile="${lemming.tile}" pos="${lemming.pos}" />`;
				}
			}

			for (let lemming of data.lemmings) {
				let el = lemmingsContainer.querySelector(`lm-lemming[color="${lemming.color}"]`);
				el.setAttribute("tile", lemming.tile);
				el.setAttribute("pos", lemming.pos);
			}

			this.querySelector("#timer > p").innerText = data.game.time_left;

			let myTurnP = this.querySelector("#my-turn");
			/** @type {HTMLButtonElement} */
			if (data.is_your_turn) {
				myTurnP.innerText = "Сейчас ваш ход";
			} else {
				myTurnP.innerText = "Сейчас чужой ход";
			}

			this.querySelectorAll(".disableable, input").forEach(e => {
				e.disabled = !data.is_your_turn;
			});

			let myLemmingP = this.querySelector("#my-lemming");
			const COLOR_TRANSLATION = {
				"red": "красный",
				"yellow": "жёлтый",
				"green": "зелёный",
				"blue": "синий",
				"purple": "фиолетовый",
				"white": "белый"
			};
			const COLOR_HEX = {
				"red": "#ff3333",
				"yellow": "#ffff33",
				"green": "#33ff33",
				"blue": "#3333ff",
				"purple": "#ff33ff",
				"white": "#ffffff"
			}
			myLemmingP.innerText = COLOR_TRANSLATION[data.role];
			myLemmingP.style.color = COLOR_HEX[data.role];

			this.lemmings = data.lemmings;

			this.setAttribute("has-hill-crashed", data.game.has_hill_crashed);
			if (this.getAttribute("has-hill-crashed") == "true" && !this.hasAttribute("hill-crash-finished")) {
				let hill = this.querySelector("li[data-type='hill']");
				hill.classList.add("crashing");
				setTimeout(() => {
					hill.classList.add("crashed");
				}, 2000);

				let water = this.querySelector("li[data-type='water']");
				water.setAttribute("data-n", "5");

				this.setAttribute("hill-crash-finished", "true");
			}

			let players = data.players;
			for (let i = 0; i < players.length; i++) {
				let p = this.querySelector(`#player-list > p[data-n="${i}"]`);
				p.innerText = players[i];
				p.setAttribute("data-current", i == parseInt(data.game.current_turn_order) - 1);
			}

			if (data.game.winner) {
				Game.emit("got-winner", {
					name: data.game.winner
				});
			}
		});

		Game.on("card-clicked", e => {
			let type = e.detail.type;
			let n = e.detail.n;

			let card = this.querySelector(`lm-card[n='${n}']`);
			card.classList.add("active");

			/** @type {HTMLFormElement} */
			let form = this.querySelector("#menu-container");
			
			let menuLemming1 = "menu-lemming-1";
			let menuLemming2 = "menu-lemming-2";
			let menuDirection = "menu-direction";
			let menuTile = "menu-tile";
			let menuConfirm = "menu-confirm";

			let menus = [];
			let allowedTiles = [];

			let hasHillCrashed = Game.getAttribute("has-hill-crashed") == "true";

			switch (type) {
				case "move_red":
				case "move_yellow":
				case "move_green":
				case "move_blue":
				case "move_purple":
				case "move_white":
					menus.push(menuDirection);
					break;

				case "jump":
					menus.push(menuLemming1);
					menus.push(menuTile);

					allowedTiles = [2, 3, 4];
					if (this.getAttribute("has-hill-crashed") != "true") {
						allowedTiles.push(5);
					}
					break;

				case "romeo":
					menus.push(menuLemming1);
					menus.push(menuLemming2);
					menus.push(menuTile);

					allowedTiles = [1, 2, 3, 4];
					if (this.getAttribute("has-hill-crashed") != "true") {
						allowedTiles.push(5);
					}
					break;

				case "whoosh":
					menus.push(menuLemming1);
					menus.push(menuLemming2);
					break;

				case "back":
					menus.push(menuLemming1);
					break;

				case "magic":
					break;

				case "crash":
					break;
			}

			menus.push(menuConfirm);

			form.reset();

			form.querySelector("input[name='card']").value = type;
			form.querySelector("input[name='n']").value = n;

			this.querySelectorAll("#menu-lemming-1 label").forEach(l => {
				let value = l.querySelector("input").getAttribute("value");
				if (menus.includes("menu-lemming-1") && this.lemmings.find(lem => lem.color == value)) {
					l.classList.add("active");
					l.querySelector("input").required = true;
				} else {
					l.classList.remove("active");
					l.querySelector("input").required = false;
				}
			});

			this.querySelectorAll("#menu-lemming-2 label").forEach(l => {
				let value = l.querySelector("input").getAttribute("value");
				if (menus.includes("menu-lemming-2") && this.lemmings.find(lem => lem.color == value)) {
					l.classList.add("active");
					l.querySelector("input").required = true;
				} else {
					l.classList.remove("active");
					l.querySelector("input").required = false;
				}
			});

			this.querySelectorAll("#menu-tile label").forEach(l => {
				let value = l.querySelector("input").getAttribute("value");
				if (menus.includes("menu-tile") && allowedTiles.includes(parseInt(value))) {
					l.classList.add("active");
					l.querySelector("input").required = true;
				} else {
					l.classList.remove("active");
					l.querySelector("input").required = false;
				}
			});

			if (hasHillCrashed) {
				this.querySelector("input[name='tile'][value='5']").setAttribute("data-type", "water");
			} else {
				this.querySelector("input[name='tile'][value='5']").setAttribute("data-type", "hill");
				this.querySelector("input[name='tile'][value='6']").setAttribute("data-type", "water");
			}

			this.querySelectorAll("#menu-container > div").forEach(menu => {
				if (menus.includes(menu.id)) {
					menu.classList.add("active");
				} else {
					menu.classList.remove("active");
				}
			});

			this.querySelectorAll("input[name='direction']").forEach(e => {
				e.required = menus.includes("menu-direction");
			});

			form.classList.add("active");
		});

		Game.on("close-menu", () => {
			this.querySelectorAll("#menu-container, #menu-container > div").forEach(e => {
				e.classList.remove("active");
			});

			this.querySelectorAll("lm-card").forEach(e => {
				e.classList.remove("active");
			});
		});

		Game.on("play-card", e => {
			Game.emit("close-menu");

			let data = e.detail;
			data.gid = this.getAttribute("gid");

			switch (data.card) {
				case "move_red":
				case "move_yellow":
				case "move_green":
				case "move_blue":
				case "move_purple":
				case "move_white":
					data["lemming-1"] = data.card.substring(5);

					Game.emit("ws", {
						event: "card-move",
						data
					});
					break;

				case "jump":
					Game.emit("ws", {
						event: "card-jump",
						data
					});
					break;

				case "romeo":
					Game.emit("ws", {
						event: "card-romeo",
						data
					});
					break;

				case "whoosh":
					Game.emit("ws", {
						event: "card-whoosh",
						data
					});
					break;

				case "back":
					Game.emit("ws", {
						event: "card-back",
						data
					});
					break;

				case "magic":
					Game.emit("ws", {
						event: "card-magic",
						data
					});
					break;

				case "crash":
					Game.emit("ws", {
						event: "card-crash",
						data
					});
					break;

			}
		});

		Game.on("next-turn", () => {
			let gid = this.getAttribute("gid");
			Game.emit("ws", {
				event: "next-turn",
				data: {
					gid
				}
			});
		});

		Game.on("got-winner", e => {
			let name = e.detail.name;
			this.finished = true;

			this.querySelector("#winner").classList.add("active");
			this.querySelector("#winner-name").innerText = name;
		});

		Game.on("go-to-lobby", () => {
			Game.goToScene("lobby");
			this.querySelector("#winner").classList.remove("active");
		});

		Game.on("quit-room", () => {
			this.setAttribute("gid", "");
		});
	}

	tick() {
		let gid = this.getAttribute("gid");
		Game.emit("ws", {
			event: "get-game-state",
			data: {
				gid
			}
		});
	}

	open() {

	}

	close() {

	}
}