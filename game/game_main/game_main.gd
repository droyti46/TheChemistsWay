extends Node2D

"""Констаны для подземелий"""
# Размер подземелья
const DUNGEON_SIZE = 5
# Размер тайла в пикселях
const TILE_SIZE = 32
# Увеличение размера спрайта в долях
const TILE_SCALE = 4
# Количество тайлов в комнате по ширине
const ROOM_COUNT_TILES_X = 11
# Количество тайлов в комнате по высоте
const ROOM_COUNT_TILES_Y = 7
# Размер комнаты по ширине в пикселях
const ROOM_SIZE_X = TILE_SIZE * TILE_SCALE * ROOM_COUNT_TILES_X
# Размер комнаты по высоте в пикселях
const ROOM_SIZE_Y = TILE_SIZE * TILE_SCALE * ROOM_COUNT_TILES_Y

func _ready():
	%DungeonGenerator.setup(DUNGEON_SIZE, 10, 1)
	var rooms: Array = %DungeonGenerator.generate_dungeon()

	var dungeon_params = {
		"rooms": rooms,
		"special_room_chance": 0.4,
		"room_size": Vector2(ROOM_SIZE_X, ROOM_SIZE_Y),
		"enemies_rooms_folder": Pathes.ROOMS_TEMPLATES_DIRECTORY + '/chapter1_forest/rooms/enemies',
		"special_rooms_folder": Pathes.ROOMS_TEMPLATES_DIRECTORY + '/chapter1_forest/rooms/special'
	}
	%Player.position.x = rooms[0].x * ROOM_SIZE_X + ROOM_SIZE_X / 2
	%Player.position.y = rooms[0].y * ROOM_SIZE_Y + ROOM_SIZE_Y / 2
	
	%Player/Camera.limit_left = rooms[0].x * ROOM_SIZE_X
	%Player/Camera.limit_right = rooms[0].x * ROOM_SIZE_X + ROOM_SIZE_X
	%Player/Camera.limit_top = rooms[0].y * ROOM_SIZE_Y
	%Player/Camera.limit_bottom = rooms[0].y * ROOM_SIZE_Y + ROOM_SIZE_Y
	
	%DungeonBuilder.build_dungeon(dungeon_params)
	# %Player.set_movement_method("grid")

func _on_player_move_next_room(direction: Vector2):
	# Ставим новые лимиты для камеры
	# Напомню, что direction - это вектор
	# left: [-1; 0], right: [1, 0]
	# top: [0, -1], bottom: [0, 1]
	%Player/Camera.limit_left += direction.x * ROOM_SIZE_X
	%Player/Camera.limit_right += direction.x * ROOM_SIZE_X
	%Player/Camera.limit_top += direction.y * ROOM_SIZE_Y
	%Player/Camera.limit_bottom += direction.y * ROOM_SIZE_Y
