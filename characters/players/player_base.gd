extends CharacterBody2D

const SPEED = 400.0

func _physics_process(_delta):
	# Получение вектора направления
	var direction = Input.get_vector("player_left",
									 "player_right",
									 "player_up",
									 "player_down")
	
	# Тело двигается в нужном направлении
	velocity = direction * SPEED
	move_and_slide()
	
	# Обработка
	if Input.is_action_just_pressed("player_left"):
		%AnimatedSprite.flip_h = true
	elif Input.is_action_just_pressed("player_right"):
		%AnimatedSprite.flip_h = false
