import GameElement from "./elements/game";

export function send(selector, eventName, data) {
	document.querySelectorAll(selector).forEach(el => {
		el.dispatchEvent(new CustomEvent(eventName, { detail: data }));
	});
}

/** @type {GameElement} */
export const Game = document.querySelector("lm-game");

export function getCookie(name) {
	return document.cookie.split("; ").find(c => c.split("=")[0] == name)?.split("=")[1];
}

export function deleteCookie(name) {
    document.cookie = name + '=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/';
}