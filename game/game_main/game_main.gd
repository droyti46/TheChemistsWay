extends Node2D

# Размер подземелья
const DUNGEON_SIZE = 5

# Словарь вида {координаты комнаты: сцена комнаты}
var rooms_scenes: Dictionary

# Положение игрока (координаты комнаты, в которой находится игрок)
var player_coords: Vector2

func _ready():
	# Коннектим нужные сигналы
	%Player.connect("move_next_room", %Ui.mini_map._on_player_move_next_room)
	
	%DungeonGenerator.setup(DUNGEON_SIZE, 10, 1)
	var rooms: Array = %DungeonGenerator.generate_dungeon()
	
	# Создаем мини-карту
	%Ui.mini_map.create_mini_map(rooms, rooms[0])
	
	var dungeon_params = {
		"rooms": rooms,
		"special_room_chance": 0.4,
		"room_size": Vector2(SpritesInfo.ROOM_SIZE_X, SpritesInfo.ROOM_SIZE_Y),
		"enemies_room": preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/rooms/enemies/room_enemies.tscn"),
		"special_rooms_folder": Pathes.ROOMS_TEMPLATES_DIRECTORY + '/chapter1_forest/rooms/special'
	}
	%Player.position.x = rooms[0].x * SpritesInfo.ROOM_SIZE_X + SpritesInfo.ROOM_SIZE_X / 2
	%Player.position.y = rooms[0].y * SpritesInfo.ROOM_SIZE_Y + SpritesInfo.ROOM_SIZE_Y / 2
	player_coords = rooms[0]
	
	%Player/Camera.limit_left = rooms[0].x * SpritesInfo.ROOM_SIZE_X
	%Player/Camera.limit_right = rooms[0].x * SpritesInfo.ROOM_SIZE_X + SpritesInfo.ROOM_SIZE_X
	%Player/Camera.limit_top = rooms[0].y * SpritesInfo.ROOM_SIZE_Y
	%Player/Camera.limit_bottom = rooms[0].y * SpritesInfo.ROOM_SIZE_Y + SpritesInfo.ROOM_SIZE_Y
	
	# Строим подземелье
	rooms_scenes = %DungeonBuilder.build_dungeon(dungeon_params)
	# %Player.set_movement_method("grid")

func _on_player_move_next_room(direction: Vector2):
	# Ставим новые лимиты для камеры
	# Напомню, что direction - это вектор
	# left: [-1; 0], right: [1, 0]
	# top: [0, -1], bottom: [0, 1]
	%Player/Camera.limit_left += direction.x * SpritesInfo.ROOM_SIZE_X
	%Player/Camera.limit_right += direction.x * SpritesInfo.ROOM_SIZE_X
	%Player/Camera.limit_top += direction.y * SpritesInfo.ROOM_SIZE_Y
	%Player/Camera.limit_bottom += direction.y * SpritesInfo.ROOM_SIZE_Y
	
	# Задаем новое положение игрока
	player_coords += direction
	
	# %Player.set_movement_method("grid")
	
	await get_tree().create_timer(0.2).timeout
	rooms_scenes[player_coords].close_doors()

func _input(event: InputEvent) -> void:
	# Код для перемещения камеры к курсору мыши
	# Код взят отсюда: https://www.youtube.com/watch?v=P0VMQ40VTtc
	if event is InputEventMouseMotion:
		var _target = event.position - get_viewport().size * 0.5
		%Player/Camera.position = _target.normalized() * _target.length() * 0.5

