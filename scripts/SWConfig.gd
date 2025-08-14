extends Node

func _ready():
	# Initialize SilentWolf
	SilentWolf.configure({
		"api_key": "YOUR_API_KEY",
		"game_id": "YOUR_GAME_ID",
		"game_version": "1.0.0",
		"log_level": 1
	})
