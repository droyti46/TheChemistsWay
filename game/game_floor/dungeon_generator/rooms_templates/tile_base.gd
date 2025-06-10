extends Node2D

var sprite_version2 = preload("res://game/game_floor/dungeon_generator/rooms_templates/chapter1_forest/tiles/sprites/forest_tile2.png")
var count_decorations = 7

var decoration_folder = "res://game/game_floor/dungeon_generator/rooms_templates/chapter1_forest/tiles/sprites/flowers/"

func _ready():
	$Sprite.material = $Sprite.material.duplicate()
	
	if randf() <= 0.5:
		$Sprite.texture = sprite_version2
	
	if randf() <= 0.3:
		$Decoration.show()
		$Decoration.position += Vector2(randi_range(-10, 10),
										randi_range(-10, 8))
		$Decoration.texture = load(
			decoration_folder + "flower" + str(randi_range(1, count_decorations)) + ".png"
		)

#func _on_mouse_handler_mouse_entered():
	#$OutlineAnimation.play("show_outline")
	#$Sprite.z_index = 1
#
#func _on_mouse_handler_mouse_exited():
	#$OutlineAnimation.play_backwards("show_outline")
	#$Sprite.z_index = 0
