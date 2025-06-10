extends Control

@export var button_text: String

signal button_clicked

func _ready():
	$ButtonText.set_text(button_text)

func _on_button_input_mouse_entered():
	$HoverAnimation.play("hover")
	$HoverAudio.play()

func _on_button_input_mouse_exited():
	$HoverAnimation.play_backwards("hover")

func _on_button_input_pressed():
	$ClickAudio.play()
	emit_signal("button_clicked")
