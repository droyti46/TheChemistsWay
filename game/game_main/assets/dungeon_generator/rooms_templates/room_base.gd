extends TileMap

@export_enum("Start", "Enemies", "Chest") var room_type = 0

var player = null

const DOORS_INFO = {
	Vector2.LEFT: {
		"alternative_index": 1,
		"coords": Vector2i(0, 3),
		"scene": preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/environment/doors/forest_door_left.tscn")
	},
	Vector2.DOWN: {
		"alternative_index": 2, 
		"coords": Vector2i(5, 6),
		"scene": preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/environment/doors/forest_door_bottom.tscn")
	},
	Vector2.RIGHT: {
		"alternative_index": 3,
		"coords": Vector2i(10, 3),
		"scene": preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/environment/doors/forest_door_right.tscn")
	},
	Vector2.UP: {
		"alternative_index": 4,
		"coords": Vector2(5, 0),
		"scene": preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/environment/doors/forest_door_top.tscn")
	}
}

func create_door(direction: Vector2) -> void:
	
	'''
	Функция для добавления двери в комнату
	
	Параметры:
		direction (String):
			left, rigth, top или bottom (сторона, в которую
			необходимо добавить дверь)
		next_pos: позиция, в которую ведет дверь
	'''
	
	if direction not in DOORS_INFO.keys():
		print("direction может принимать лишь значения " + 
			  "left, right, top и bottom")
		return
	
	# Загрузка информации из DOORS_INFO
	var door_coords: Vector2i = DOORS_INFO[direction]["coords"]
	var door_scene: StaticBody2D = DOORS_INFO[direction]["scene"].instantiate()
	
	# Установка положения двери
	door_scene.position = map_to_local(door_coords)
	# Добавление ноды двери
	%Doors.add_child(door_scene)
	
	# Удаление стены (клетки, на которой
	# сейчас находится дверь)
	erase_cell(0, door_coords)

func close_doors() -> void:
	
	"""
	Проигрывает анимацию закрытия дверей
	"""
	
	for door in %Doors.get_children():
		door.close_door()

func set_player(new_player: Node2D, pos) -> void:
	var player_coords: Vector2i
	match pos:
		"central":
			player_coords = Vector2i(SpritesInfo.ROOM_COUNT_TILES_X,
						 			 SpritesInfo.ROOM_COUNT_TILES_Y) / 2
		Vector2i.LEFT:
			player_coords = Vector2i(SpritesInfo.ROOM_COUNT_TILES_X - 1, 
						 			 SpritesInfo.ROOM_COUNT_TILES_Y / 2)
		Vector2i.RIGHT:
			player_coords = Vector2i(0, 
						 			 SpritesInfo.ROOM_COUNT_TILES_Y / 2)
		Vector2i.UP:
			player_coords = Vector2i(SpritesInfo.ROOM_COUNT_TILES_X / 2, 
									 SpritesInfo.ROOM_COUNT_TILES_Y - 1)
		Vector2i.DOWN:
			player_coords = Vector2i(SpritesInfo.ROOM_COUNT_TILES_X / 2, 
									 0)

	new_player.position = map_to_local(player_coords)
	add_child(new_player)
	player = new_player
	
	player.set_coords("player", player_coords)
	player.set_coords("obstacles", get_used_cells(SpritesInfo.OBSTACLES_TILEMAP_LAYER))

func delete_player() -> void:
	remove_child(player)

func get_type() -> String:
	return ["Start", "Enemies", "Chest"][room_type]
