extends CharacterBody2D

const SPEED = 400

# Двигается ли птичка сейчас
var is_moving: bool = false
# Направление, в котором двигается птичка
var direction: Vector2

func _on_area_2d_body_entered(body):
	# Если птичка уже движется, то никаких действий
	# не требуется
	if is_moving:
		return
	# Вектор направления
	direction = (position - body.position).normalized()
	# Анимация поднятия
	$AnimatedSprite.play("stay")
	# Ожидание конца поднятия
	await $AnimatedSprite.animation_finished
	# Проигрывание анимации полёта и полёт
	$AnimatedSprite.play("fly")
	is_moving = true
	
func _physics_process(delta):
	# Если птичка летит
	if is_moving:
		# То двигаем её
		velocity = direction * SPEED
		move_and_slide()
	# Включение отражения по горизонтали, если птичка летит вправо
	if velocity.x > 0:
		$AnimatedSprite.flip_h = true

func _on_visible_on_screen_screen_exited():
	queue_free()

