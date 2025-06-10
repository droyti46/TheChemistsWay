extends Node2D

var substance: Substance
var count: int
var collected: bool = false

func set_substance(substance: Substance, count) -> void:
	self.substance = substance
	self.count = count
	$GameSubstance.show()
	$GameSubstance.setup(substance, count)

func _on_player_handler_body_entered(body):
	if collected:
		return
	collected = true
	Game.game.ui.add_substance(substance, count)
	$CollectAudio.play()
	hide()
	await $CollectAudio.finished
	queue_free()
