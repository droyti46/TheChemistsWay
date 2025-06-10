extends "res://characters/enemies/enemy_base.gd"

"""
Подробнее читать в enemies.md
"""

var attack_preload = preload("res://characters/enemies/fish/attack/fish_attack.tscn")

# Все атаки монстра
var attacks: Array = []
# Должен ли монстр атаковать игрока на текущем ходу или нет
var is_attacking: bool
# Текущая сцена атаки (если атакует)
var current_attack_scene
# Направление, в котором летит атака, если монстр атакует
var attack_direction: Vector2i
# Координаты, в которых должна заспавниться атака
var attack_coords: Vector2i

func delete_created_objects():
	# Проходится по всем атакам и, если это не null,
	# удаляет её
	# null может быть, когда пуля уже самоуничтожилась
	for attack in attacks:
		if attack != null:
			attack.queue_free()

func random_attack(map, attack_vector, obstacles_coords) -> void:
	
	"""
	Функция для совершения случайной атакм
	"""
	
	# Выбираем тайл, на который монстр будет стрелять
	@warning_ignore("shadowed_variable")
	var attack_coords = enemy_coords + attack_vector
	
	# Если этот тайл не валидный, то ничего не делаем
	if not Utils.coords_is_valid(attack_coords, obstacles_coords):
		return
	
	# Иначе со случайным шансом происходит атака
	if randi_range(0, 100) <= 50:
		# Добавление индикатора атаки на карту
		#map.add_attacked_tile(attack_coords, self)
		current_attack_scene = attack_preload.instantiate()
		current_attack_scene.create_attack_indicator(attack_coords)
		# Игрок должен атаковать на следующем ходу,
		# так что заполняем необходимые переменные
		# для атаки
		is_attacking = true
		attack_direction = attack_vector
		self.attack_coords = enemy_coords

func make_move(map: TileMap,
			   player_coords: Vector2i,
			   other_enemies_coords: Array):
	
	"""
	Метод для совершения хода
	"""
	
	# Проход по всем атакам и атака
	for attack in attacks:
		# Если атака равна null, то переходим к следующей
		if not attack:
			continue

		# Делаем ход
		attack.make_move(
			map,
			player_coords,
			other_enemies_coords
		)
	
	# Если персонаж атакует
	if is_attacking:
		# Координаты атаки
		current_attack_scene.position = map.map_to_local(attack_coords)
		current_attack_scene.set_coords(attack_coords)
		# Выставляем направление атаки
		current_attack_scene.direction = attack_direction
		
		# Добавляем сцену атаки на карту
		map.add_child(current_attack_scene)
		# Анимация атаки
		current_attack_scene.make_move(
			map,
			player_coords,
			other_enemies_coords
		)
		# Спрайт атаки
		animated_sprite.play("attack_%s" % last_direction)
		attacks.append(current_attack_scene)
		
		is_attacking = false
		return
	
	# Достаем координаты препятствий
	var obstacles_coords = map.get_obstacles_coords()
	
	# Ход в случайном направлении
	var random_direction = Movements.random_step(
		enemy_coords,
		Utils.merge_arrays([obstacles_coords, player_coords, other_enemies_coords])
	)
	enemy_coords += random_direction

	set_step_animation(random_direction)
	step_animate(random_direction, true)
	random_attack(map, random_direction,
		Utils.merge_arrays([obstacles_coords, other_enemies_coords])
	)
