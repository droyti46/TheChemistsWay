class_name Indicator
extends Node

# Прелоад индикатора
var indicator_preload = preload("res://game/game_floor/dungeon_generator/assets/indicator/indicator_visual.tscn")

var indicator_visual: Node2D
# Текущие координаты индикатора
var current_coords: Vector2i
# Комната
var room: TileMap
var indicator_enemy: Node2D

func _init(
	coords: Vector2i,
	damage: int,
	map: TileMap,
	enemy: Node2D
	):
	# Настройка атрибутов
	current_coords = coords
	room = map
	indicator_enemy = enemy
	# Добавление индикатора в комнату
	var indicator_scene = indicator_preload.instantiate()
	indicator_visual = indicator_scene
	indicator_scene.position = map.map_to_local(coords)
	map.get_node("Indicators").add_child(indicator_scene)

func move(direction: Vector2i) -> void:
	var new_coords = current_coords + direction
	var new_position = room.map_to_local(new_coords)
	current_coords = new_coords
	indicator_visual.move_to(new_position)
	
func delete() -> void:
	indicator_visual.delete()
	indicator_enemy.indicators.erase(self)
	await indicator_visual.deleted
	queue_free()
