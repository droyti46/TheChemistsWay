extends "res://characters/enemies/enemy_base.gd"

"""
Подробнее читать в enemies.md
"""

func make_move(map: TileMap,
			   player_coords: Vector2i,
			   other_enemies_coords: Array) -> Vector2i:
	
	"""
	Метод для совершения хода
	"""
	
	# Достаем координаты препятствий
	var obstacles_coords = map.get_used_cells(SpritesInfo.OBSTACLES_TILEMAP_LAYER)
	
	# Создание массива ходов, которыми монстр может походить
	var available_offsets: Array = []
	for offset in [Vector2i.LEFT,
				   Vector2i.RIGHT,
				   Vector2i.UP,
				   Vector2i.DOWN]:
		var new_enemy_coords = enemy_coords + offset
		#if new_enemy_coords not in obstacles_coords and new_enemy_coords not in other_enemies_coords:
		if Utils.coords_is_valid(new_enemy_coords, player_coords, obstacles_coords, other_enemies_coords):
			available_offsets.append(offset)
	
	# Проверка, есть ли вообще доступные направления
	# Может быть так, что монстр заперт и доступных путей нет
	if available_offsets:
		# Если есть возможные пути, то
		# Выбор случайного направления
		var random_offset: Vector2i = available_offsets[randi() % available_offsets.size()]
		enemy_coords += random_offset
		return random_offset
	# Иначе никуда не двигаемся, то есть возвращаем нулевой вектор
	return Vector2i.ZERO
