extends "res://characters/enemies/enemy_base.gd"

signal attack_collapsed

# Сторона, в которую летит пуля
var direction: Vector2i
# Враг, к которому привязана атака
var enemy = null

func make_move(map: TileMap,
			   player_coords: Vector2i,
			   _other_enemies_coords: Array):
	
	"""
	Метод для совершения хода
	"""
	
	var obstacles_coords = map.get_used_cells(SpritesInfo.OBSTACLES_TILEMAP_LAYER)
	var new_attack_cords = enemy_coords + direction
	
	if not Utils.coords_is_valid(enemy_coords, obstacles_coords):
		get_indicator_with_coords(enemy_coords).delete()
		queue_free()
		return
	
	if new_attack_cords == player_coords:
		map.player.game.ui.health_bar.damage(damage_count)
	
	if Utils.coords_is_valid(new_attack_cords, obstacles_coords):
		get_indicator_with_coords(new_attack_cords).move(direction)
	
	enemy_coords += direction
	step_animate(direction, false, 0.2)
