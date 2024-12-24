import { Game } from "../../index.js";
import SceneElement from "../scene.js";

export default class GameSceneElement extends SceneElement {
	static observedAttributes = ["has-hill-crashed"];

	/** @type {number} */
	timer;

	/** @type {string[]} */
	hand = [];

	/** @type {string[]} */
	lemmings = [];

	connectedCallback() {
		Game.on("game-started", () => {
			this.tick();
			this.timer = setInterval(this.tick, 1000);
		});

		Game.on("incoming-game-state", e => {
			if (!this.isOpen()) {
				return;
			}

			let data = e.detail;

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

			let turnStarted = new Date(data.game.current_turn_started + "Z").valueOf();
			let turnDuration = parseInt(data.game.turn_duration) * 1000;
			let now = new Date().valueOf();
			let timerP = this.querySelector("#timer > p");
			timerP.innerText = Math.floor((turnStarted + turnDuration - now) / 1000);

			let turnIndicator = this.querySelector("#turn-indicator");
			if (data.is_your_turn) {
				turnIndicator.innerText = "THIS IS YOUR TURN!!!!!! GOOOOOOOOO";
			} else {
				turnIndicator.innerText = "NOT YOUR TURN HOLD UP!!!!!!!";
			}

			this.lemmings = data.lemmings;

			this.setAttribute("has-hill-crashed", data.game.has_hill_crashed);
			if (this.getAttribute("has-hill-crashed") == "true" && !this.hasAttribute("hill-crash-finished")) {
				let hill = this.querySelector("li[data-type='hill']");
				hill.classList.add("crashing");
				setTimeout(() => {
					hill.style.display = "none";
				}, 2000);

				let water = this.querySelector("li[data-type='water']");
				water.setAttribute("data-n", "5");

				this.setAttribute("hill-crash-finished", "true");
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

			this.querySelectorAll("#menu-lemming-1 label, #menu-lemming-2 label").forEach(l => {
				let value = l.querySelector("input").getAttribute("value");
				if (this.lemmings.find(lem => lem.color == value)) {
					l.classList.add("active");
				} else {
					l.classList.remove("active");
				}
			});

			this.querySelectorAll("#menu-tile label").forEach(l => {
				let value = l.querySelector("input").getAttribute("value");
				if (allowedTiles.includes(parseInt(value))) {
					l.classList.add("active");
				} else {
					l.classList.remove("active");
				}
			});

			if (n != 1) {
				this.querySelector("#menu-direction label:has(input[value='left']").classList.add("active");
			}

			if (hasHillCrashed) {
				if (n == 5) {
					this.querySelector("#menu-direction label:has(input[value='right']").classList.remove("active");
				} else {
					this.querySelector("#menu-direction label:has(input[value='right']").classList.add("active");
				}
			} else {
				if (n == 6) {
					this.querySelector("#menu-direction label:has(input[value='right']").classList.remove("active");
				} else {
					this.querySelector("#menu-direction label:has(input[value='right']").classList.add("active");
				}
			}

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
			data.n = `${parseInt(data.n) + 1}`;

			switch (data.card) {
				case "move_red":
				case "move_yellow":
				case "move_green":
				case "move_blue":
				case "move_purple":
				case "move_white":
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
			Game.emit("ws", {
				event: "next-turn"
			});
		});
	}

	tick() {
		Game.emit("ws", {
			event: "get-game-state"
		});
	}

	open() {

	}

	close() {

	}
}