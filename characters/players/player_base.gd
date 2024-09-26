extends CharacterBody2D

'''
Скрипт базового персонажа
'''
signal move_next_room

# Скорость персонажа
const SPEED: float = 400.0
# Количество пикселей, на которое телепортируется
# игрок, когда войдет в дверь
const ADD_NEXT_POS: int = 256

# Переменная, в которой хранится направление, в которое двигался
# персонаж перед тем как игрок отжал кнопку
# Может принимать значения "side", "behind" или "front"
var last_direction: String = "side"

# Переменная, отвечающая за способ передвижения:
# free - свободное передвижение
# grid - передвижение по клеткам
var movement_method: String = "free"

"""Переменные, которые нужны для пошагового
перемещения по клеткам"""
# Размер плитки
var tile_size = 32 * 4
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

func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2

func _physics_process(_delta) -> void:
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
				position += door_direction * ADD_NEXT_POS
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
					# То передвигаем персонажа по сетке
					_grid_move(dir)
				else:
					# Иначе просто ставим анимацию
					_set_configure_sprite(dir)

func _grid_move(dir: String) -> void:
	# Включение необходимой анимации
	_set_configure_sprite(dir)
	# Создание Tween для перемещения
	var tween = create_tween()
	tween.tween_property(self, "position",
		position + inputs[dir] * tile_size, 1.0 / animation_speed)
	moving = true
	await tween.finished
	moving = false
	%AnimatedSprite.play("idle_%s" % last_direction)

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
