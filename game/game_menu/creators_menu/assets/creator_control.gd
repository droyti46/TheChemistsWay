extends Control

@export var creator_name: String
@export var creator_nickname: String
@export var creator_role: String

func _ready():
	$Content/CreatorName.set_text(creator_name)
	$Content/CreatorNickname.set_text("(" + creator_nickname + ")")
	$Content/CreatorRole.set_text(creator_role)
	
	if not creator_nickname:
		$Content/CreatorNickname.queue_free()
		custom_minimum_size.y = 72
