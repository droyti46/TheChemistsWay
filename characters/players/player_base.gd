extends CharacterBody2D

'''
Скрипт базового персонажа
'''

@onready var camera = $Camera

# Сигнал перемещения персонажа в другую комнату
signal move_next_room
# Совершен ход
signal grid_move_finished
# Закончилось здоровье
signal health_is_over
# Закончились ходы
signal moves_are_over

# Скорость персонажа
const SPEED: float = 400.0
# Количество пикселей, на которое телепортируется
# игрок, когда войдет в дверь
const ADD_NEXT_POS: int = 245
# Количество ходов
const MAX_MOVES: int = 2

# Переменная, в которой хранится направление, в которое двигался
# персонаж перед тем как игрок отжал кнопку
# Может принимать значения "side", "behind" или "front"
var last_direction: String = "side"

# Переменная, отвечающая за способ передвижения:
# free - свободное передвижение
# grid - передвижение по клеткам
var movement_method: String = "free"
# Текущее количество ходов
var remained_moves: int = MAX_MOVES
# Может ли персонаж пошагово ходить
# (выключается, пока ходят враги)
var can_step: bool = true

"""Переменные, которые нужны для пошагового
перемещения по клеткам"""
# Actions и вектора
var inputs = {
	"player_right": Vector2.RIGHT,
	"player_left": Vector2.LEFT,
	"player_up": Vector2.UP,
	"player_down": Vector2.DOWN
}
# Скорость анимации перемещения
var animation_speed = 3
# Перемещается ли персонаж сейчас (относится только
# к методу перемещения grid)
var moving = false

"""Переменные, в которые записана информация о
текущей комнате (в которой находится игрок)"""
# Координаты игрока в текущей комнате
var player_coords: Vector2i
# Координаты всех препятствий и врагов
var obstacles_coords: Array
var enemies_coords: Array

func _set_configure_sprite(dir: String) -> void:
	
	'''
	Функция для настройки спрайта персонажа,
	в зависимости от того, в какую сторону он идет
	
	Параметры:
		dir (String):
			В зависимости от направления может принимать
			4 значения:
			player_left, player_right, player_up, player_down
	'''
	
	match dir:
		"player_left":
			# Поворот спрайта персонажа
			%AnimatedSprite.flip_h = true
			# Проигрывание анимации
			%AnimatedSprite.play("step_side")
			# Последнее направление
			last_direction = "side"
		"player_right":
			# Поворот спрайта персонажа
			%AnimatedSprite.flip_h = false
			# Проигрывание анимации
			%AnimatedSprite.play("step_side")
			# Последнее направление
			last_direction = "side"
		"player_up":
			# Проигрывание анимации
			%AnimatedSprite.play("step_behind")
			# Последнее направление
			last_direction = "behind"
		"player_down":
			# Проигрывание анимации
			%AnimatedSprite.play("step_side")
			# Последнее направление
			last_direction = "side"

func _process(_delta) -> void:
	# Если метод перемещения free, т.е. свободный
	if movement_method == "free":
		# Получение вектора направления
		var direction: Vector2 = Input.get_vector("player_left",
										 		  "player_right",
										 		  "player_up",
										 		  "player_down")
		
		# Персонаж двигается в нужном направлении
		velocity = direction * SPEED
		move_and_slide()
		
		# Проверяем столкновения
		for i in get_slide_collision_count():
			var collider = get_slide_collision(i).get_collider()
			# Если персонаж столкнулся и у объекта
			# есть метод get_direction, то есть объект -
			# это дверь и у него можно получить направление,
			# в котором он стоит
			if collider.has_method("get_direction"):
				var door_direction: Vector2 = collider.get_direction()
				# Персонаж меняет положение
				# position += door_direction * ADD_NEXT_POS
				# Вызывается сигнал
				emit_signal("move_next_room", door_direction)
				break
		
		# Если вектор направления нулевой (т.е. мы персонаж не двигается
		# и стоит на месте)
		if not direction:
			# Играется анимация idle на основе направления,
			# которое принимал персонаж до того как остановился
			%AnimatedSprite.play("idle_%s" % last_direction)

func _unhandled_input(event) -> void:
	
	'''
	Обработка нажатия клавиш
	'''
	
	# Если персонаж ещё не перемещается
	if not moving:
		# Проходимся по каждому направлению
		for dir in inputs.keys():
			# Если нажата эта кнопка
			if event.is_action_pressed(dir):
				# Если персонаж сейчас перемещается методом
				# grid
				if movement_method == "grid":
					# Если мы не можем передвинуться,
					# то просто прекращаем работу
					if not Utils.coords_is_valid(
						player_coords + Vector2i(inputs[dir].x, inputs[dir].y),
						Utils.merge_arrays([obstacles_coords, enemies_coords])
					) or not can_step:
						# Проигрывание анимации, что не может идти
						%CantStepAnimation.play("cant_step")
						return
					# То передвигаем персонажа по сетке
					_grid_move(dir)
				else:
					# Иначе просто ставим анимацию
					_set_configure_sprite(dir)

func _grid_move(dir: String) -> void:
	# Перемещение
	player_coords += Vector2i(inputs[dir].x, inputs[dir].y)
	# Включение необходимой анимации
	_set_configure_sprite(dir)
	# Создание Tween для перемещения
	var tween = create_tween()
	tween.tween_property(self, "position",
		position + inputs[dir] * SpritesInfo.TILE_SIZE, 1.0 / animation_speed)
	moving = true
	await tween.finished
	moving = false
	%AnimatedSprite.play("idle_%s" % last_direction)
	# Сигнал
	emit_signal("grid_move_finished", inputs[dir])
	# Уменьшение количества ходов, так как персонаж
	# уже походил
	_reduce_moves()

func set_movement_method(method: String) -> void:
	
	'''
	Функция, чтобы задать петод перемещения
	
	Параметры:
		method (String): метод перемещения
			может принимать значения "free" или "grid"
	'''
	
	if method not in ["free", "grid"]:
		print("Метод перемещения может быть только free или grid!")
		return
	
	movement_method = method
	
	# Если выбран метод перемещения по клеткам
	if movement_method == "grid":
		# Анимация idle
		$AnimatedSprite.play("idle_side")

func _reduce_moves():
	remained_moves -= 1
	if not remained_moves:
		emit_signal("moves_are_over")
		remained_moves = MAX_MOVES

func set_coords(coords_type: String, coords) -> void:
	
	"""
	Метод, устанавливающий игроку координаты
	игрока, врага или препятствий
	это необходимо, чтобы игрок мог видеть карту
	"""
	
	if coords_type not in ["player", "enemies", "obstacles"]:
		print(
			"Недопустимое значение параметра coords_type!"
		)
		return
	
	match coords_type:
		"player":
			player_coords = coords
		"enemies":
			enemies_coords = coords
		"obstacles":
			obstacles_coords = coords

func set_can_step(value: bool) -> void:
	can_step = value

func get_max_moves() -> int:
	return MAX_MOVES
