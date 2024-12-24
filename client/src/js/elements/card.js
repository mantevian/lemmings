import { Game } from "../index.js";
import CustomElement from "./element.js";

export default class CardElement extends CustomElement {
	static observedAttributes = ["type", "n"];

	connectedCallback() {
		this.addEventListener("click", () => {
			Game.emit("card-clicked", {
				type: this.getAttribute("type"),
				n: this.getAttribute("n")
			});
		});
	}

	attributeChangedCallback(name, oldValue, newValue) {
		if (name == "type") {
			this.style.backgroundImage = `url('/assets/cards/${newValue}.svg')`;
		}
	}
}