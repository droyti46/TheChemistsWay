extends Node2D

# Насколько сильно кусты при старте будут шататься
const START_OFFSET_MAX: int = 20

# Список, в котором хранятся прелоады всех спрайтов
# лесных кустов
var sprites: Array = [
	preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/environment/walls/sprites/walls1.png"),
	preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/environment/walls/sprites/walls2.png")
]

func _ready():
	# Выбор случайного спрайта из возможных и установка его
	# в качестве спрайта стен
	var sprite: Texture = sprites[randi() % sprites.size()]
	$Sprite.texture = sprite
	
	# Чуть-чуть передвигаем куст, чтобы стоял не идеально
	var offset: Vector2 = Vector2(
		randf_range(-START_OFFSET_MAX, START_OFFSET_MAX),
		randf_range(-START_OFFSET_MAX, START_OFFSET_MAX)
	)
	position += offset
	# z_index = randi_range(0, 10)
