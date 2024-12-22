import CustomElement from "./element";

const ERRORS = {
	not_connected: "Нет подключения",
	user_already_exists: "Такой пользователь уже зарегистрирован",
	short_password: "Пароль должен быть длиннее 4 символов",
	not_registered: "Вы не зарегистрированы",
	wrong_password: "Неправильный пароль",
	user_not_found: "Пользователь не найден",
	room_not_found: "Комната не найдена",
	already_in_room: "Вы уже находитесь в комнате",
	this_room_is_already_playing: "В этой комнате уже идёт игра",
	room_is_full: "Эта комната уже заполнена",
	not_in_room: "Вы не находитесь в комнате",
	not_enough_players: "Недостаточно игроков для начала игры",
	cant_play_cards: "Вы сейчас не можете разыгрывать карты",
	wrong_card: "Неверная информация о карте",
	invalid_direction: "Направление может быть только влево (left) или вправо (right)",
	cant_move: "Этого лемминга невозможно передвинуть",
	out_of_bounds: "Переданная позиция находится вне поля",
	incorrect_color: "Лемминг такого цвета не найден",
	two_same_lemmings: "Нужно выбрать леммингов разных цветов",
	no: "Действие недопустимо"
};

export default class ErrorElement extends CustomElement {
	static observedAttributes = ["type"];

	connectedCallback() {

	}

	attributeChangedCallback(name, oldValue, newValue) {
		if (name != "type") {
			return;
		}

		this.querySelector("p.description").innerText = ERRORS[newValue] || "Неизвестная ошибка";
		this.classList.add("active");

		setTimeout(() => {
			this.classList.remove("active");
		}, 5000);
	}
}