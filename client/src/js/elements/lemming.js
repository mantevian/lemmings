import { Game } from "../index.js";
import CustomElement from "./element.js";

export default class LemmingElement extends CustomElement {
	static observedAttributes = ["color", "tile", "pos"];

	connectedCallback() {

	}

	attributeChangedCallback(name, oldValue, newValue) {
		let tile = parseInt(this.getAttribute("tile"));
		let pos = parseInt(this.getAttribute("pos"));

		let crashed = Game.getScene("game").getAttribute("has-hill-crashed") === "true";
		let water = crashed && tile == 5 || !crashed && tile == 6;
		if (water) {
			this.style.translate = `${(tile - 1) * (192 + 48 - (pos % 2) * 32)}px ${-pos * 25 + this.parentElement.offsetHeight + 50}px`;
		} else {
			this.style.translate = `${(tile - 1) * (192 + 32)}px ${-pos * 25 + this.parentElement.offsetHeight + 25}px`;
		}
	}
}