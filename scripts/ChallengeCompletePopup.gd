extends Control

# Signal emitted when popup is closed
signal popup_closed

func _ready():
	# Hide popup initially
	hide()

func show_popup(challenge_name: String, reward_text: String):
	# Update popup content
	$PopupPanel/VBoxContainer/ChallengeName.text = challenge_name
	$PopupPanel/VBoxContainer/RewardLabel.text = reward_text
	
	# Show popup
	show()

func _on_ClaimButton_pressed():
	emit_signal("popup_closed")
	hide()

func _on_Background_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("popup_closed")
	hide()
