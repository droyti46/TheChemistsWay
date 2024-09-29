extends Node2D

# Размер подземелья
const DUNGEON_SIZE = 5

# Словарь вида {координаты комнаты: сцена комнаты}
var rooms_scenes: Dictionary

# Нода игрока
var player = preload("res://characters/players/player_base.tscn").instantiate()
# Положение игрока (координаты комнаты, в которой находится игрок)
var player_room_coords: Vector2i
# Координаты игрока в комнате
var player_coords: Vector2i

func _ready():
	# Коннектим нужные сигналы
	player.connect("grid_move_finished", _on_player_grid_move_finished)
	player.connect("moves_are_over", _on_player_moves_are_over)
	player.connect("move_next_room", _on_player_move_next_room)
	player.connect("move_next_room", %Ui.mini_map._on_player_move_next_room)
	
	%DungeonGenerator.setup(DUNGEON_SIZE, 10, 1)
	var rooms: Array = %DungeonGenerator.generate_dungeon()
	
	# Создаем мини-карту
	%Ui.mini_map.create_mini_map(rooms, rooms[0])
	
	var dungeon_params = {
		"rooms": rooms,
		"special_room_chance": 0.4,
		"room_size": Vector2i(SpritesInfo.ROOM_SIZE_X, SpritesInfo.ROOM_SIZE_Y),
		"enemies_room": preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/rooms/enemies/room_enemies.tscn"),
		"special_rooms_folder": Pathes.ROOMS_TEMPLATES_DIRECTORY + '/chapter1_forest/rooms/special'
	}
	# %Player.position.x = rooms[0].x * SpritesInfo.ROOM_SIZE_X + SpritesInfo.ROOM_SIZE_X / 2
	# %Player.position.y = rooms[0].y * SpritesInfo.ROOM_SIZE_Y + SpritesInfo.ROOM_SIZE_Y / 2
	
	# Строим подземелье
	rooms_scenes = %DungeonBuilder.build_dungeon(dungeon_params)
	
	rooms_scenes[rooms[0]].set_player(player, "central")
	player_room_coords = rooms[0]
	
	player.camera.limit_left = rooms[0].x * SpritesInfo.ROOM_SIZE_X
	player.camera.limit_right = rooms[0].x * SpritesInfo.ROOM_SIZE_X + SpritesInfo.ROOM_SIZE_X
	player.camera.limit_top = rooms[0].y * SpritesInfo.ROOM_SIZE_Y
	player.camera.limit_bottom = rooms[0].y * SpritesInfo.ROOM_SIZE_Y + SpritesInfo.ROOM_SIZE_Y

func _on_player_move_next_room(direction: Vector2i):
	# Ставим новые лимиты для камеры
	# Напомню, что direction - это вектор
	# left: [-1; 0], right: [1, 0]
	# top: [0, -1], bottom: [0, 1]
	player.camera.limit_left += direction.x * SpritesInfo.ROOM_SIZE_X
	player.camera.limit_right += direction.x * SpritesInfo.ROOM_SIZE_X
	player.camera.limit_top += direction.y * SpritesInfo.ROOM_SIZE_Y
	player.camera.limit_bottom += direction.y * SpritesInfo.ROOM_SIZE_Y
	
	rooms_scenes[player_room_coords].delete_player()
	
	# Задаем новое положение игрока
	player_room_coords += direction
	
	rooms_scenes[player_room_coords].set_player(player, direction)
	
	#player.set_movement_method("grid")
	
	await get_tree().create_timer(0.2).timeout
	rooms_scenes[player_room_coords].close_doors()

func _on_player_moves_are_over():
	rooms_scenes[player_room_coords].make_moves(player_coords)

func _on_player_grid_move_finished(direction: Vector2i):
	
	"""
	Функция срабатывает, когда игрок походил пешком
	"""
	
	# Выбор текущей комнаты
	var current_room = rooms_scenes[player_room_coords]
	# Присваивание координаты игроку
	player_coords = current_room.local_to_map(current_room.player.position)
