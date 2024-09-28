extends "res://characters/enemies/enemy_base.gd"

"""
Подробнее читать в enemies.md
"""

func make_move(map: TileMap,
			   player_pos: Vector2,
			   other_enemies_pos: Array):
	
	"""
	Метод для совершения хода
	"""
	
	var obstacles_coords = map.get_used_cells(SpritesInfo.OBSTACLES_TILEMAP_LAYER)
	
	var available_offsets: Array = []
	for offset in [Vector2.LEFT,
				   Vector2.RIGHT,
				   Vector2.UP,
				   Vector2.DOWN]:
		var new_enemy_pos = enemy_pos + offset
		if new_enemy_pos not in obstacles_coords and new_enemy_pos not in other_enemies_pos:
			available_offsets.append(offset)
	
	var random_offset: Vector2 = available_offsets[randi() % available_offsets.size()]
	enemy_pos += random_offset
	
	return random_offset
