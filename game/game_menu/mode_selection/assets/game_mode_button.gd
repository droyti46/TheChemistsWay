extends Control

signal click

@export var mode_name: String
@export_multiline var mode_desc: String
@export var mode_image: Texture2D

func _ready():
	%ModeImage.texture = mode_image
	$ModeNameLabel.set_text(mode_name)
	$ModeDescLabel.set_text(mode_desc)

func _on_button_mouse_entered():
	$HoverAudio.play()
	$Animation.play("hover")
	
func _on_button_mouse_exited():
	$Animation.play_backwards("hover")

func _on_button_pressed():
	$ClickAudio.play()
	emit_signal("click")
