import CustomElement from "./element.js";

export default class LemmingElement extends CustomElement {
	static observedAttributes = ["color", "tile", "pos"];

	connectedCallback() {

	}

	attributeChangedCallback(name, oldValue, newValue) {
		let tile = parseInt(this.getAttribute("tile"));
		let pos = parseInt(this.getAttribute("pos"));

		this.style.background = this.getAttribute("color");
		this.style.translate = `${(tile - 1) * (192 + 32)}px ${-pos * 70 + this.parentElement.offsetHeight}px`;
	}
}