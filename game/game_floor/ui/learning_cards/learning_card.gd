extends Control

const CARDS = [
	{
		"video": "step.ogv",
		"text": "Передвигайтесь на WASD"
	},
	
	{
		"video": "to_room.ogv",
		"text": "Заходите в комнаты, чтобы начать бой"
	},

	{
		"video": "grid_step.ogv",
		"text": "В режиме боя вы передвигаетесь пошагово"
	},
	
	{
		"video": "attack.ogv",
		"text": "Перетяните вещество на близко стоящего врага (в пределах одной клетки), чтобы атаковать его"
	},
	
	{
		"video": "create_substances.ogv",
		"text": "Объедините два вещества, чтобы получать новые"
	},

	{
		"video": "damage_player.ogv",
		"text": "Берегитесь красных клеток! Они находятся под атакой врага"
	},
]

var current_i = 0

func _set_learning():
	if current_i >= len(CARDS):
		$ShowAnimation.play_backwards("show")
		await $ShowAnimation.animation_finished
		queue_free()
		return
		
	var video = load("res://game/game_floor/ui/learning_cards/videos/" + CARDS[current_i]["video"])
	var text = CARDS[current_i]["text"]
	%Video.stream = video
	%Video.play()
	$NextAnimation.play("next")
	%Text.set_text(text)

func _on_next_button_click():
	current_i += 1
	_set_learning()

func _ready():
	$ShowAnimation.play("show")
	_set_learning()
	pass
