import { Game, getCookie } from "../../index.js";
import SceneElement from "../scene.js";

export default class AccountSceneElement extends SceneElement {
	static observedAttributes = [];

	connectedCallback() {
		Game.on("got-my-login", e => {
			this.querySelector("h1 > span").innerText = e.detail;
		});

		Game.on("logout", () => {
			Game.emit("ws", {
				event: "logout"
			});
		});

		Game.on("logout-everywhere", () => {
			Game.emit("ws", {
				event: "logout-everywhere"
			});
		});
	}

	open() {
		
	}

	close() {
		
	}
}