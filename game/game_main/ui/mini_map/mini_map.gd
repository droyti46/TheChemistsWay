extends TileMap

# Текущая позиция игрока
var player_position: Vector2

func _on_player_move_next_room(direction: Vector2) -> void:
	
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

func create_mini_map(rooms: Array, start_position: Vector2) -> void:
	
	"""
	Метод для создания карты на основе списка координат комнат
	
	Параметры:
		room (Array): список комнат
		start_position (Vector2): стартовая позиция игрока
	"""
	
	# Устанавливаем позицию игрока, как изначальную
	player_position = start_position
	# Перемещение игрока
	$MiniMapEntered.position = map_to_local(start_position)
	
	# Добавление комнат на TileMap
	for room in rooms:
		set_cell(0, room, 2, Vector2i(0, 0))
