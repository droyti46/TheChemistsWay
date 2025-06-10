extends TextureProgressBar

# Сигнал получения урона
signal received_damage
# Сигнал смерти (когда здоровье у объекта заканчивается)
signal died

var current_health = 0

func setup(health: int) -> void:
	
	"""
	Функция для настройки Хелл Бара
	Получает на вход количество здоровья у сущности
	"""
	
	max_value = health
	value = health
	current_health = health
	$HealthLabel.set_text("%d/%d" % [max_value, max_value])

func damage(damage_count: int) -> void:
	
	"""
	Функция для нанесения урона объекту
	"""
	
	current_health = current_health - damage_count
	
	var tween = create_tween()
	tween.tween_property(
		self,
		"value",
		current_health,
		0.3
	)
	$HealthLabel.set_text(
		"%d/%d" % [max(0, current_health), max_value]
	)
	
	if current_health <= 0:
		emit_signal("died")
	else:
		emit_signal("received_damage", damage_count)

func get_health():
	return current_health
