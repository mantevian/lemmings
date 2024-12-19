import { Game, send } from "../index.js";
import CustomElement from "./element.js";

export default class EventElement extends CustomElement {
	static observedAttributes = [];

	connectedCallback() {
		let on = this.getAttribute("on") ?? "";
		let event = (this.getAttribute("event") ?? "click");
		let data = this.getAttribute("data") ?? "{}";

		this.parentElement.addEventListener(on, () => {
			Game.emit(event, {
				data,
				sender: this.parentElement
			});
		});
	}
}