extends Node2D

const PATH_TO_LOCATION_TEMPLATE = ""
const LEVELS_INFO = [
	{
		"chapter": 1,
		"location": "forest",
		"enemies": ["fish", "bomb"]
	},

	{
		"chapter": 1,
		"location": "forest",
		"enemies": ["fish", "bomb", "circular_mushroom"]
	},
	
	{
		"chapter": 1,
		"location": "forest",
		"enemies": ["fish", "bomb", "circular_mushroom"]
	},
]

var current_level = 0

func _change_floor():
	var level_info = LEVELS_INFO[current_level]

func _ready():
	pass
