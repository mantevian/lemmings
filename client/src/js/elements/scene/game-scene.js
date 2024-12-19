import { Game } from "../../index.js";
import SceneElement from "../scene.js";

export default class GameSceneElement extends SceneElement {
	static observedAttributes = [];

	/** @type {number} */
	timer;

	/** @type {string[]} */
	hand = [];

	connectedCallback() {
		Game.on("game-started", () => {
			this.tick();
			this.timer = setInterval(this.tick, 1000);
		});

		Game.on("incoming-game-state", e => {
			let data = e.detail;

			let deckElement = this.querySelector("ul#deck");

			let len1 = this.hand.length;
			let len2 = data.hand.length;

			let changed = false;
			if (len1 != len2) {
				changed = true;
			} else {
				for (let i = 0; i < len1; i++) {
					if (this.hand[i] != data.hand[i]) {
						changed = true;
					}
				}
			}

			if (changed) {
				deckElement.replaceChildren([]);

				for (let card of data.hand) {
					deckElement.innerHTML += `<li><lm-card type="${card}" /></li>`;
				}
			}
			
			// this.innerHTML = JSON.stringify(data);
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