import { Game } from "..";

export default class CustomFormElement extends HTMLFormElement {
	static observedAttributes = [];

	connectedCallback() {
		this.addEventListener("submit", e => {
			e.preventDefault();

			let event = this.getAttribute("event");

			if (event == "ws") {
				Game.emit("ws", {
					event: this.getAttribute("action"),
					data: new FormData(this)
				});
			} else {
				Game.emit(this.getAttribute("event"), Object.fromEntries(new FormData(this).entries()));
			}
		});
	}
}