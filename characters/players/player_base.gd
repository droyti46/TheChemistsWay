extends CharacterBody2D

# Скорость персонажа
const SPEED: float = 400.0

# Переменная, в которой хранится направление, в которое двигался
# персонаж перед тем как игрок отжал кнопку
# Может принимать значения "side", "behind" или "front"
var last_direction: String = "side"

'''Переменные, которые нужны для пошагового
перемещения по клеткам'''
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
# Перемещается ли персонаж сейчас
var moving = false

func _set_configure_sprite(dir: String):
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

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2

#func _physics_process(_delta):
	## Получение вектора направления
	#var direction: Vector2 = Input.get_vector("player_left",
									 		  #"player_right",
									 		  #"player_up",
									 		  #"player_down")
	#
	## Персонаж двигается в нужном направлении
	#velocity = direction * SPEED
	#move_and_slide()
	#
	## Если вектор направления нулевой (т.е. мы персонаж не двигается
	## и стоит на месте)
	#if not direction:
		## Играется анимация idle на основе направления,
		## которое принимал персонаж до того как остановился
		#%AnimatedSprite.play("idle_%s" % last_direction)
	#
	## Обработка клавиш
	#for dir in inputs.keys():
		#if event.is_action_pressed(dir):
			#_set_configure_sprite(dir)
			#break

func _unhandled_input(event):
	# Если персонаж уже не перемещается
	if not moving:
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				_move(dir)
				break

func _move(dir: String):
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
