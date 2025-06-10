extends Node2D

# Размер подземелья
const DUNGEON_SIZE = 5

# Пользовательский интерфейс
@onready var ui = %Ui

# Словарь вида {координаты комнаты: сцена комнаты}
# ВНИМАНИЕ: для получения комнаты, в которой сейчас
# находится игрок, следует использовать функцию
# get_current_room(), а не обращаться к словарю напрямую
var rooms_scenes: Dictionary

# Нода игрока
var player = preload("res://characters/players/tony/tony.tscn").instantiate()
# Положение игрока (координаты комнаты, в которой находится игрок)
var player_room_coords: Vector2i
# Координаты игрока в комнате
var player_coords: Vector2i

func _ready() -> void:
	# Добавляем себя в глобальные переменные
	Game.game = self
	
	# Коннектим нужные сигналы
	player.connect("grid_move_finished", _on_player_grid_move_finished)
	player.connect("moves_are_over", _on_player_moves_are_over)
	player.connect("move_next_room", _on_player_move_next_room)
	player.connect("move_next_room", ui.mini_map._on_player_move_next_room)
	player.game = self
	
	%DungeonGenerator.setup(DUNGEON_SIZE, 10, 1)
	var rooms: Array = %DungeonGenerator.generate_dungeon()
	
	# Устанавливаем количесто ходов
	ui.set_moves(player.get_max_moves())
	# Устанавливаем начальные вещества
	ui.set_substances(player.base_substances)
	# Устанавливаем здоровье персонажа
	ui.health_bar.setup(player.health)
	ui.health_bar.connect("received_damage", player._received_damage)
	
	var dungeon_params = {
		"rooms": rooms,
		"special_room_chance": 0.4,
		"room_size": Vector2i(SpritesInfo.ROOM_SIZE_X, SpritesInfo.ROOM_SIZE_Y),
		"start_room": preload("res://game/game_floor/dungeon_generator/rooms_templates/chapter1_forest/forest_room_base.tscn"),
		"enemies_room": preload("res://game/game_floor/dungeon_generator/rooms_templates/chapter1_forest/rooms/enemies/room_enemies.tscn"),
		"chest_room": preload("res://game/game_floor/dungeon_generator/rooms_templates/chapter1_forest/rooms/special/forest_room_chest.tscn")
	}
	
	# Строим подземелье
	rooms_scenes = %DungeonBuilder.build_dungeon(dungeon_params)
	# Создаем мини-карту
	ui.mini_map.create_mini_map(rooms_scenes, rooms[0])
	
	rooms_scenes[rooms[0]].set_player(player, "central")
	player_room_coords = rooms[0]
	
	player.camera.limit_left = rooms[0].x * SpritesInfo.ROOM_SIZE_X
	player.camera.limit_right = rooms[0].x * SpritesInfo.ROOM_SIZE_X + SpritesInfo.ROOM_SIZE_X
	player.camera.limit_top = rooms[0].y * SpritesInfo.ROOM_SIZE_Y
	player.camera.limit_bottom = rooms[0].y * SpritesInfo.ROOM_SIZE_Y + SpritesInfo.ROOM_SIZE_Y

func _on_player_move_next_room(direction: Vector2i) -> void:
	
	"""
	Функция срабатывает, когда игрок переместился в другую комнату
	
	Параметры:
		direction (Vector2i):
			Направление перемещения, в какой стороне
			находится новая комната, то есть Vector2i.LEFT,
			Vector2i.RIGHT, Vector2i.DOWN или Vector2i.UP
	"""
	
	# Ставим новые лимиты для камеры
	# direction - это вектор
	# left: [-1; 0], right: [1, 0]
	# top: [0, -1], bottom: [0, 1]
	player.camera.limit_left += direction.x * SpritesInfo.ROOM_SIZE_X
	player.camera.limit_right += direction.x * SpritesInfo.ROOM_SIZE_X
	player.camera.limit_top += direction.y * SpritesInfo.ROOM_SIZE_Y
	player.camera.limit_bottom += direction.y * SpritesInfo.ROOM_SIZE_Y
	
	# Удаляем всю информацию о координатам у игрока
	player.reset_coords()
	
	# Получаем старую комнату и удаляем из нее игрока
	var old_room = rooms_scenes[player_room_coords]
	old_room.delete_player()
	# Прячем старую комнату
	old_room.hide_room()
	
	# Если старая комната имела тип Enemies
	if old_room.get_type() == "Enemies":
		# То отвязываем сигнал
		old_room.disconnect("enemies_finished_moves",
							_on_enemies_finished_moves)
	
	# Задаем новые координаты комнаты, в которой находится игрок
	player_room_coords += direction
	# Получаем новую комнату и спавним в ней игрока
	var new_room = rooms_scenes[player_room_coords]
	new_room.set_player(player, direction)
	
	# Показываем новую комнату
	new_room.show_room()
	
	# Если тип новой комнаты Enemies
	if new_room.get_type() == "Enemies":
		# Анимация интерфейса для сражения
		ui.fight_animation()
		
		# Ставим игроку координаты всех врагов
		player.set_coords("enemies", new_room.get_enemies_coords())
		
		# Подключение сигналов
		new_room.connect(
			"enemies_finished_moves",
			_on_enemies_finished_moves
		)
		new_room.connect(
			"room_is_passed",
			_on_room_is_passed
		)
		new_room.fight_started()
		
		# Метод передвижения grid у игрока
		player.set_movement_method("grid")
		#get_current_room().player.set_can_step(true)
		
		# Обновляем количество ходов игрока
		ui.reload_moves()
		
		# Ждем некоторое время и закрываем двери
		await get_tree().create_timer(0.2).timeout
		new_room.close_doors()
		
	elif new_room.get_type() == "Last":
		$UICanvas/EndGame/Show.play("show")

func _on_player_moves_are_over() -> void:
	
	"""
	Функция вызывается, когда у врагов закончились ходы
	"""
	
	# Останавливаем игрока
	get_current_room().player.set_can_step(false)
	# Теперь ходят монстры
	get_current_room().make_moves(player_coords)
	ui.reload_moves()
	#await get_tree().create_timer(0.05).timeout
	get_current_room().player.set_can_step(true)

func _on_player_grid_move_finished(direction: Vector2i) -> void:
	
	"""
	Функция срабатывает, когда игрок походил пешком
	"""
	
	# Присваивание координаты игроку
	player_coords = get_current_room().local_to_map(get_current_room().player.position)
	# Уменьшаем количество ходов
	ui.reduce_moves()

func _on_enemies_finished_moves() -> void:
	
	"""
	Функция срабатывает, когда все монстры в комнате походили
	"""
	
	# Обновление ходов
	# ui.reload_moves()
	# Теперь игрок может ходить
	#get_current_room().player.set_can_step(true)
	
	pass

func _on_room_is_passed() -> void:
	
	"""Функция срабатывает, когда текущая комната пройдена
	(то есть игрок убил всех врагов)"""
	
	# Анимация завершения сражения
	ui.fight_finished_animation()
	
	# Метод передвижения free у игрока
	player.set_movement_method("free")
	
	# Открываем двери
	get_current_room().fight_finished()
	get_current_room().open_doors()
	
	# Спавн сундука
	if randf() <= 0.4:
		get_current_room().spawn_chest()

func get_current_room() -> TileMap:
	
	"""
	Функция для получения комнаты, в которой игрок в текущий
	момент находится
	"""
	
	# Возвращаем rooms_scenes по индексу player_room_coords
	# room scenes - это словарь, в котором ключами являются
	#				координаты, а значениями - сцены комнат
	#				в этих координатах.
	# player_room_coords - вектор с координатами комнатами,
	#				в которой сейчас находится игрок
	return rooms_scenes[player_room_coords]

func hide_hud() -> void:
	
	"""
	Функция прячет весь GUI и HUD на экране
	"""
	
	$UICanvas.hide()

func show_hud() -> void:
	
	"""
	Функция показывает весь GUI и HUD на экране
	"""
	
	$UICanvas.show()
