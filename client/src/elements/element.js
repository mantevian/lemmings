export default class CustomElement extends HTMLElement {
	constructor() {
		super();
	}

	connectedCallback() {
		this.render();
	}

	render() {

	}

	attributeChangedCallback(name, oldValue, newValue) {
		this.render();
	}
}