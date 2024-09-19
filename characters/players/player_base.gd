extends CharacterBody2D

const SPEED = 400.0

func _physics_process(_delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("player_left",
									 "player_right",
									 "player_up",
									 "player_down")
	
	velocity = direction * SPEED
	move_and_slide()
	
	if Input.is_action_just_pressed("player_left"):
		%AnimatedSprite.flip_h = true
	elif Input.is_action_just_pressed("player_right"):
		%AnimatedSprite.flip_h = false
