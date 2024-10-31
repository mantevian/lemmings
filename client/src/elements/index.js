const prefix = "lm";

const elements = {

};

for (let e of Object.entries(elements)) {
	customElements.define(`${prefix}-${e[0]}`, e[1]);
}