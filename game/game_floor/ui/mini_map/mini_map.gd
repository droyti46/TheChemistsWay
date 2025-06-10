extends TileMap

# Текущая позиция игрока
var player_position: Vector2i
# Словарь комнат {координаты: сцена_комнаты}
var rooms: Dictionary

var visited: Array[Vector2i] = []

func _show_nearest_rooms() -> void:
	
	"""
	Функция для показа игроку ближайших к его
	местоположению комнат
	"""
	
	set_cell(0, player_position, 4, Vector2i(0, 0))
	
	for offset in [Vector2i.LEFT,
				   Vector2i.RIGHT, 
				   Vector2i.UP,
				   Vector2i.DOWN]:
		var room_position: Vector2i = player_position + offset
		if room_position in rooms.keys():
			if room_position not in get_used_cells(0):
				set_cell(0, room_position, 2, Vector2i(0, 0))
			match rooms[room_position].get_type():
				"Chest":
					set_cell(1, room_position, 0, Vector2i(0, 0))
				"Last":
					set_cell(1, room_position, 1, Vector2i(0, 0))

func _on_player_move_next_room(direction: Vector2i) -> void:
	
	"""
	Функция для обработки сигнала при перемещении игрока в новую
	комнату
	"""
	
	# Прибавляет к позиции игрока направление
	player_position += direction
	# Анимируем
	var tween: Tween = create_tween()
	tween.tween_property($MiniMapEntered, "position",
		map_to_local(player_position), 0.3).set_trans(Tween.TRANS_SINE)
		
	# Показываем ближайшие комнаты
	_show_nearest_rooms()

func create_mini_map(rooms_map: Dictionary, start_position: Vector2) -> void:
	
	"""
	Метод для создания карты на основе списка координат комнат
	
	Параметры:
		rooms_map (Dictionary): словарь комнат вида
								{координаты: сцена_комнаты}
		start_position (Vector2): стартовая позиция игрока
	"""
	
	rooms = rooms_map
	
	# Устанавливаем позицию игрока, как изначальную
	player_position = start_position
	# Перемещение игрока
	$MiniMapEntered.position = map_to_local(start_position)
	
	# Добавление комнат на TileMap
	_show_nearest_rooms()
