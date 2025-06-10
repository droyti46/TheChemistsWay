extends Button

@export var link: String

func _on_mouse_entered():
	$HoverAudio.play()
	$Animation.play("hover")

func _on_mouse_exited():
	$Animation.play_backwards("hover")

func _on_pressed():
	OS.shell_open(link)
