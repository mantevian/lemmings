import { Game, getCookie } from "../../index.js";
import SceneElement from "../scene.js";

export default class InfoSceneElement extends SceneElement {
	static observedAttributes = [];

	connectedCallback() {
		Game.on("got-my-login", e => {
			this.querySelector(".my-name").innerText = e.detail;
		});
	}

	open() {
		
	}

	close() {
		
	}
}