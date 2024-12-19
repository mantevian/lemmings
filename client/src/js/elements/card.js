import CustomElement from "./element.js";

export default class CardElement extends CustomElement {
	static observedAttributes = ["type"];

	connectedCallback() {

	}

	attributeChangedCallback(name, oldValue, newValue) {
		if (name == "type") {
			this.innerHTML = newValue;
		}
	}
}