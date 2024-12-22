import CustomElement from "./element.js";

export default class SceneElement extends CustomElement {
	static observedAttributes = [];

	connectedCallback() {

	}

	open() {
		
	}

	close() {
		
	}

	/** @returns {boolean} */
	isOpen() {
		return this.hasAttribute("active");
	}
}