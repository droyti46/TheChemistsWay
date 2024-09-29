extends Sprite2D

var animation_speed = 3
var enemy_coords: Vector2i

signal step_finished

func set_coords(new_coords: Vector2i) -> void:
	"""Функция ставит координаты монстра"""
	enemy_coords = new_coords
	
func get_coords() -> Vector2i:
	"""Метод для получения координат врага"""
	return enemy_coords

func step_animate(direction: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "position",
		position + direction * SpritesInfo.TILE_SIZE, 1.0 / animation_speed)
	await tween.finished
	emit_signal("step_finished")
	

