import { Game } from "..";

export default class CustomFormElement extends HTMLFormElement {
	static observedAttributes = [];

	connectedCallback() {
		this.addEventListener("submit", e => {
			e.preventDefault();

			Game.emit("ws", {
				event: this.getAttribute("action"),
				data: new FormData(this)
			});
		});
	}
}