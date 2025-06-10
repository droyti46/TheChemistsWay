extends Control

@export var button_text: String

signal click

func _ready():
	$ButtonText.set_text(button_text)

func _on_button_mouse_entered():
	$HoverAudio.play()
	$Animation.play("hover")

func _on_button_mouse_exited():
	$Animation.play_backwards("hover")

func _on_button_pressed():
	emit_signal("click")
