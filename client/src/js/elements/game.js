import { deleteCookie, getCookie } from "../index.js";
import CustomElement from "./element.js";

export default class GameElement extends CustomElement {
	static observedAttributes = [];

	connectedCallback() {
		window.addEventListener("load", () => {
			this.removeAttribute("style");
			this.goToScene(this.getAttribute("scene"));

			this.resize();
			window.addEventListener("resize", () => {
				this.resize();
			});

			setTimeout(() => {
				this.handleSocket();

				this.on("go-to-scene", e => {
					this.goToScene(e.detail.data);
				});
			}, 500);
		});
	}

	handleSocket() {
		let socket = new WebSocket("/ws");

		socket.onopen = () => {

		};

		socket.onmessage = e => {
			let cmd = e.data.split(" ")[0];
			let data = JSON.parse(e.data.split(" ").slice(1).join(" ") || "{}");

			if (!(["get-game-state", "get-room-list"].includes(cmd)) && data.result && data.result != "ok") {
				this.querySelector("lm-error").setAttribute("type", data.result);
			} 

			switch (cmd) {
				case "connected":
					if (data.login) {
						this.goToScene("lobby");
					} else {
						this.goToScene("login");
					}
					break;

				case "register":
					if (data.result == "ok") {
						this.goToScene("lobby");
					}
					break;

				case "auth":
					if (data.result == "ok") {
						this.goToScene("lobby");
					}
					break;

				case "change-password":
					if (data.result == "ok") {
						this.goToScene("login");
					}
					break;

				case "logout":
					if (data.result == "ok") {
						this.goToScene("login");
					}
					break;

				case "logout-everywhere":
					if (data.result == "ok") {
						this.goToScene("login");
					}
					break;

				case "get-room-list":
					this.getScene("lobby").updateList(data);
					break;

				case "create-room":

					break;

				case "join-room":
					if (data.result == "ok") {
						this.emit("open-room-dialog", data);
					}
					break;

				case "start-game":
					if (data.result == "ok") {
						this.emit("game-started");
						this.goToScene("game");
					}
					break;

				case "get-game-state":
					if (data.result == "ok") {
						this.emit("incoming-game-state", data);
					}
					break;

				case "get-my-login":
					if (data.result == "ok") {
						this.emit("got-my-login", data.login);
					}
					break;
			}
		};

		this.on("ws", e => {
			let data = e.detail.data ?? {};

			let token = getCookie("lemmings-token");

			if (!token) {
				location.reload();
			}

			if (typeof data == "string") {
				socket.send(`${token} ${e.detail.event} ${e.detail.data}`);
				return;
			}

			if (data instanceof FormData) {
				socket.send(`${token} ${e.detail.event} ${JSON.stringify(Object.fromEntries(e.detail.data.entries()))}`);
				return;
			}

			socket.send(`${token} ${e.detail.event} ${JSON.stringify(data)}`);
		});
	}

	resize() {
		let parent = this.parentElement.getBoundingClientRect();
		let scale = Math.min(parent.width / 1600, parent.height / 900) * 0.98;
		this.style.transform = `scale(${scale * 100}%)`;
		
		document.querySelectorAll("dialog").forEach(dialog => {
			dialog.style.transform = `scale(${scale * 100}%)`;
		});
	}

	goToScene(sceneName) {
		if (!sceneName) {
			return;
		}

		let currScene = this.querySelector(`:scope > *[active]`);
		currScene?.removeAttribute("active");
		currScene?.close();

		let nextScene = this.querySelector(`lm-${sceneName}-scene`);
		nextScene?.setAttribute("active", "");
		nextScene?.open();
	}

	on(type, listener) {
		this.addEventListener(type, listener);
	}

	once(type, listener) {
		this.addEventListener(type, listener, { once: true });
	}

	off(type, listener) {
		this.removeEventListener(type, listener);
	}

	emit(type, detail) {
		return this.dispatchEvent(new CustomEvent(type, { detail }));
	}

	getScene(sceneName) {
		for (let i = 0; i < this.children.length; i++) {
			let scene = this.children[i];
			if (sceneName == scene.tagName.split("-").slice(1, -1).join("-").toLowerCase()) {
				return scene;
			}
		}
	}
}