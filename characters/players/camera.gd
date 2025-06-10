extends Camera2D

func _physics_process(_delta):
	# Установка положения позиции курсора, деленной на два
	# Это чтобы камера персонажа чуть-чуть двигалась за мышкой
	position = get_local_mouse_position() / 2
