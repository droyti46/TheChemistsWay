extends "res://characters/enemies/enemy_base.gd"

var attacked_tiles = []

func _check_attack(map, player_coords: Vector2i):
	var vector_dist = abs(player_coords - enemy_coords)
	if (vector_dist.x in [0, 1]) and (vector_dist.y in [0, 1]):
		for i in range(-1, 2):
			for j in range(-1, 2):
				#map.add_attacked_tile(enemy_coords + Vector2i(i, j),
									   #self)
				create_attack_indicator(enemy_coords + Vector2i(i, j))
				attacked_tiles.append(enemy_coords + Vector2i(i, j))
		$BreathAudio.play()
		return true
	return false

func make_move(map: TileMap,
			   player_coords: Vector2i,
			   other_enemies_coords: Array):
	
	"""
	Метод для совершения хода
	"""
	
	if attacked_tiles:
		if player_coords in attacked_tiles:
			damage_player(map)
		
		for tile in attacked_tiles:
			get_indicator_with_coords(tile).delete()
		
		attacked_tiles = []
		
		_check_attack(map, player_coords)
		return
	
	if _check_attack(map, player_coords): return
	
	var obstacles = Utils.merge_arrays([
		map.get_obstacles_coords(),
		other_enemies_coords
	])
	var direction = Movements.step_to_player(
		enemy_coords,
		player_coords,
		obstacles
	)
	
	enemy_coords += direction
	_check_attack(map, player_coords)
	$AnimatedSprite.flip_h = player_coords.x - enemy_coords.x < 0
	$AnimatedSprite.play("shell_step")
	step_animate(direction, false, 0.3)
	await step_finished
	$AnimatedSprite.play("shell_idle")
