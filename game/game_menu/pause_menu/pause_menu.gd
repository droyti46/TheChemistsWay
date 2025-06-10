extends Control

var is_paused: bool = false

func _input(event):
	if Input.is_action_just_pressed("exit"):
		$ShowPauseAudio.play()
		if is_paused:
			_close_pause()
		else:
			_open_pause()

func _open_pause() -> void:
	is_paused = true
	$ShowAnimation.play("show")
	$Menu.show()
	get_tree().paused = true
	Game.game.hide_hud()

func _close_pause() -> void:
	is_paused = false
	$ShowAnimation.play_backwards("show")
	$Menu.hide()
	get_tree().paused = false
	Game.game.show_hud()
	
func _on_continue_button_click():
	_close_pause()

func _on_exit_button_click():
	Game.main.to_main_menu(true)
	_close_pause()
