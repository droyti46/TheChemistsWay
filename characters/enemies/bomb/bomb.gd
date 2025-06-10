extends "res://characters/enemies/enemy_base.gd"

"""
Алгоритм:
	- Проверка, можно ли взорваться:
		- Подготовка
		- Взрыв
	- Ход в сторону игрока
	- Провека, можно ли взорваться:
		- Подготовка
		- Взрыв
"""

var is_explosing = false
var attacked_coords = []

func _can_explosion(player_coords, my_coords) -> bool:
	# Вектор расстояния между игроком и монстром
	var vector_dist = abs(player_coords - my_coords)
	return (vector_dist.x in [0, 1]) and (vector_dist.y in [0, 1])

func _make_explosion(my_coords: Vector2i,
					   map: TileMap) -> void:
	# Монстр взрывается
	is_explosing = true
	# Расставляем индикаторы атаки
	for i in range(-2, 3):
		for j in range(-2, 3):
			if abs(i) - abs(j) == 0 and abs(i) == 2: continue
			var offset = [abs(i), abs(j)]
			offset.sort()
			if abs(abs(i) - abs(j)) == 1 and offset == [1, 2]: continue
			#map.add_attacked_tile(
				#my_coords + Vector2i(i, j),
				#self
			#)
			create_attack_indicator(my_coords + Vector2i(i, j))
			attacked_coords.append(my_coords + Vector2i(i, j))

func make_move(map: TileMap,
			   player_coords: Vector2i,
			   other_enemies_coords: Array):
	
	"""
	Метод для совершения хода
	"""

	if is_explosing:
		# бьем игрока если он злой
		if player_coords in attacked_coords:
			damage_player(map)
		$ExplosionAudio.play()
		$ExplosionParticles.emitting = true
		$AnimatedSprite.hide()
		await $ExplosionAudio.finished
		_death(false)
		return
	
	if not is_explosing and _can_explosion(player_coords, enemy_coords):
		_make_explosion(
			enemy_coords,
			map,
		)
		step_animate(Vector2i.ZERO)
		return
	
	var obstacles = map.get_obstacles_coords() + other_enemies_coords
	var direction = Movements.step_to_player(
		enemy_coords,
		player_coords,
		obstacles
	)
	
	#var new_enemy_coords = enemy_coords + direction
	enemy_coords += direction
	
	# Проверка взрыва
	if not is_explosing and _can_explosion(player_coords, enemy_coords):
		_make_explosion(
			enemy_coords,
			map,
		)
		
	$AnimatedSprite.flip_h = player_coords.x - enemy_coords.x < 0
	
	$AnimatedSprite.play("jump")
	await $AnimatedSprite.animation_finished
	$JumpAnimation.play("jump")
	$AnimatedSprite.play("idle")
	step_animate(direction)
