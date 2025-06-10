extends StaticBody2D

# Сторона, в которой находится дверь
@export_enum("Left", "Right", "Top", "Bottom") var direction

# Та же сторона, но в векторном виде
# Например, если дверь находится на левой стороне,
# то принимает значение Vector2.LEFT
var direction_vector: Vector2
# Закрыта ли чейчас дверь или нет

func _ready() -> void:
	# Смотрим на значение direction и выставляем
	# направление в векторном виде
	match direction:
		0:
			direction_vector = Vector2.LEFT
		1:
			direction_vector = Vector2.RIGHT
		2:
			direction_vector = Vector2.UP
		3:
			direction_vector = Vector2.DOWN

func get_direction() -> Vector2:
	
	'''
	Функция для получения координат, в которые переместит
	эта комната
	
	Например, если стороны находится справа
	
	. . .
	. . Д
	. . .
	
	То вернет Vector.RIGHT
	
	Если сверху
	
	. Д .
	. . .
	. . .
	
	То вернет Vector.UP
	'''
	
	$OpenDoorPlayer.play()
	return direction_vector

func close_door() -> void:
	$AnimatedSprite.play("close")

func open_door() -> void:
	$AnimatedSprite.play_backwards("close")
