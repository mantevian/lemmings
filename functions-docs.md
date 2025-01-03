# Лемминги — документация по функциям

## Кратко — как пользоваться

Взаимодействие с клиентом происходит посредством передачи токена — все функции, кроме функции получения токена, требуют токен. Для начала нужно заполучить токен, если у вас его ещё нет, с помощью функции: `select connect('')` с пустой строкой.

Используя полученный токен, можно зарегистрироваться, наприемр: `select register('my_name', '123456', TOKEN)` (подставить токен). Теперь вам доступна основная часть игры.

Чтобы создать комнату, нужно использовать, например `select create_room(120, 4, TOKEN)` — создаст игру на 4 человек, 120 секунд на ход. В таком случае, когда к комнате присоединятся 4 человека, игра автоматически запустится. Получить список доступных игр можно через `select get_room_list(TOKEN)`, а присоединиться по `select join_room(jc, TOKEN)`, где jc — join_code, четырёхбуквенный код игры.

Для вызова функций требуется помимо токена ID игры (GID), чтобы указать, в какой именно игре выполняется действие, т.к. игрок может одновременно быть в разных играх с одного логина. Этот ID получается из ответа на `join_room`. Клиентское приложение должно его запомнить и отправлять с каждым запросом в соответствующие функции.

В игре запоминается время начала хода. Когда игрок пытается походить после окончания хода, ход переключается. Предполагается, что веб-сервер для каждого игрока каждую секунду вызывает `select get_game_state(TOKEN, GID)` — по этой функции можно получить всю необходимую для клиента информацию об игре (включая роль игрока, которую по задумке игры Лемминги нужно держать в секрете от других), вызов этой функции также переключает ход при истечении времени хода. В процессе игры пользователи разыгрывают карты функциями `card_*` и могут досрочно закончить свой ход функцией `next_turn`. Игроки могут подключаться к одной игре с нескольких устройств. Из игры можно отключаться (`select quit_room(TOKEN, GID)`) и возвращаться обратно (`join_room(jc, TOKEN)`), при этом лемминг игрока не удаляется.

Игра заканчивается, когда ровно один лемминг остаётся на суше. Обращайте внимание на номера полей, т.к. карта Обвал может уменьшить их общее количество с 6 до 5, т.е. поле с водой меняет номер. Проверка условия победы осуществляется при смене хода. Если есть победивший, игра приостанавливается. Игроки получают имя победившего игрока через функцию `get_game_state(TOKEN, GID)`, в случае его наличия клиентское приложение должно сопроводить пользователя выйти из комнаты. Когда все пользователи вышли из уже начатой игры любым способом, эта игра удаляется.

## Публичные функции

### connect

```sql
connect (tk varchar)
```

Подключение пользователя к сети. Если он присылает несуществующий токен, создать новый и вернуть его. Если клиент присылает правильный токен, вернуть обратно его.

### register

```sql
register (lg varchar, pw varchar, tk varchar)
```

Регистрация пользователя. Также логинит пользователя при успешной регистрации.

### auth

```sql
auth (lg varchar, pw varchar, tk varchar)
```

Аутентификация пользователя. Создаётся связь переданного токена с логином.

### get_my_login

```sql
get_my_login (tk varchar)
```

Возвращает логин пользователя.

### change_password

```sql
change_password (pw varchar, newpw varchar, tk varchar)
```

Смена пароля пользователем. Разлогинивает пользователя со всех устройств.

### logout

```sql
logout (tk varchar)
```

Деаутентификация пользователя. Удаляется связь между переданным токеном и логином.

### logout_everywhere

```sql
logout_everywhere (tk varchar)
```

Деаутентификация пользователя на всех устройствах. Удаляет все связи логина пользователя и его токенов.

### get_room_list

```sql
get_room_list (tk varchar)
```

Вызывается клиентом, когда нужно присоединить пользователя к лобби. Возвращает список доступных игр.

### create_room

```sql
create_room (dur integer, pc integer, tk varchar)
```

Используется игроками для создания комнаты. Возвращает обратно данные об игре, а также 4-значный код для подключения.

### join_room

```sql
join_room (jc varchar, tk varchar)
```

Присоединяет игрока к комнате по 4-значному коду. Возвращает список игроков в этой комнате. К комнате нельзя присоединиться, если там уже идёт игра.

### quit_room

```sql
quit_room (tk varchar, gid integer)
```

Отключает игрока из комнаты. Вызывается, когда игрок выходит из игры. Если этот игрок больше не находится в этой игре ни с одного подключения, ходы этого игрока пропускаются.

### get_game_state

```sql
get_game_state (tk varchar, gid integer)
```

Возвращает всё состояние игры.

### next_turn

```sql
next_turn (tk varchar, gid integer)
```

Вызывается игроком для окончания своего хода. Количество карт на руке этого игрока восполняется до трёх из колоды игры. Ход переходит игроку со следующим порядком хода, сбрасывается время начала хода.

### card_move

```sql
card_move (tk varchar, gid integer, col color, direction varchar)
```

Играет обычную карту передвижения лемминга. Принимает цвет и направление (left/right). Направление не имеет значения, если лемминг находится на самой левой или самой правой клетке поля.

### card_jump

```sql
card_jump (tk varchar, gid integer, col color, target_tile integer)
```

Играет карту Прыжок. Принимает цвет и позицию на отрезке [2, 5] (если уже был сыгран Обвал, то [2, 4]).

> Перемести одного любого лемминга в любое место, кроме норы и воды (без стоящих на нём).

### card_romeo

```sql
card_romeo (tk varchar, gid integer, col1 color, col2 color, target_tile integer)
```

Играет карту Ромео и Джульетта. Принимает два цвета леммингов для перемещения, а также позицию [1, 6] или [1, 5] после Обвала. Перемещает этих леммингов на одну клетку без других леммингов, сидящих выше них. Если на целевой клетке уже есть лемминги, выбранные ставятся сверху.

> Перемести двух любых леммингов на любое место, кроме воды (без стоящих на них).

### card_whoosh

```sql
card_whoosh (tk varchar, gid integer, col1 color, col2 color)
```

Играет карту Вжух. Принимает два цвета леммингов. Меняет местами этих двух леммингов без других леммингов, стоящих на них.

> Поменяй местами двух любых леммингов (без стоящих на них).

### card_back

```sql
card_back (tk varchar, gid integer, col color)
```

Играет карту Назад. Принимает цвет лемминга. Передвигает его на две клетки назад вместе со всеми леммингами выше него.

> Любой лемминг двигается назад на два шага вместе со всеми стоящими на нём леммингами.

### card_magic

```sql
card_magic (tk varchar, gid integer)
```

Играет карту Волшебная дудочка. Все лемминги двигаются на одну клетку вправо, сохраняя положение друг на друге.

> Все лемминги двигаются на шаг вперёд, сохраняя своё расположение друг на друге.

### card_crash

```sql
card_crash (tk varchar, gid integer)
```

Играет карту Обвал. Удаляет клетку hill, все лемминги на ней перемещаются в воду. Может быть сыграна только один раз за игру, поэтому удаляется из колоды вместо перемещения в колоду игры.

> Убери поле, ближайшее к воде. Все лемминги с него падают в воду.