import CardElement from "./card";
import ErrorElement from "./error";
import EventElement from "./event";
import CustomFormElement from "./form";
import GameElement from "./game";
import LemmingElement from "./lemming";
import SceneElement from "./scene";
import GameSceneElement from "./scene/game-scene";
import LoadingSceneElement from "./scene/loading-scene";
import LobbySceneElement from "./scene/lobby-scene";
import LoginSceneElement from "./scene/login-scene";
import RegisterSceneElement from "./scene/register-scene";

const prefix = "lm";

const elements = {
	"game": GameElement,
	"event": EventElement,
	"card": CardElement,
	"lemming": LemmingElement,
	"error": ErrorElement,
	"scene": SceneElement,
	"login-scene": LoginSceneElement,
	"register-scene": RegisterSceneElement,
	"lobby-scene": LobbySceneElement,
	"loading-scene": LoadingSceneElement,
	"game-scene": GameSceneElement,
};

for (let e of Object.entries(elements)) {
	customElements.define(`${prefix}-${e[0]}`, e[1]);
}

customElements.define(`${prefix}-form`, CustomFormElement, { extends: "form" });