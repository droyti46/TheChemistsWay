extends Node2D

"""
Класс индикатора атаки
"""

# Враг, к которому привязан индикатор атаки
var enemy = null
# Координаты индикатора
var coords = null

signal deleted

func delete() -> void:
	
	"""Метод для удаления"""
	
	$Animation.play_backwards("show")
	await $Animation.animation_finished
	emit_signal("deleted")
	queue_free()

func move_to(new_position: Vector2) -> void:
	
	"""
	Функция, чтобы переместить индикатора
	Принимает на вход новое положение
	"""
	
	# Анимируем
	var tween = create_tween()
	tween.tween_property(
		self,
		"position",
		new_position,
		0.2
	).set_trans(Tween.TRANS_QUINT)
