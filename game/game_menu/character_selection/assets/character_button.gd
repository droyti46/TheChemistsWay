extends Control

const CHARACTER_PATH = "res://characters/players/%s/"
const BTN_IMAGE_PATH = CHARACTER_PATH + "/sprites/side/idle/idle_side.png"

func init(character: String) -> void:
	$CharacterImage.texture = load(BTN_IMAGE_PATH % character)
	$CharacterName.set_text(character)
	
func _on_button_mouse_entered():
	$HoverAudio.play()
	$Animation.play("hover")

func _on_button_mouse_exited():
	$Animation.play_backwards("hover")
