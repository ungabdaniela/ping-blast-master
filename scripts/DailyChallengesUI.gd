extends Control

# References
var challenge_manager: Node
var challenges_container: VBoxContainer

func _ready():
	# Get reference to challenge manager
	challenge_manager = get_node("/root/DailyChallengeManager")
	
	# Connect to challenge manager signals
	challenge_manager.connect("challenges_updated", self, "_on_challenges_updated")
	
	# Get UI references
	challenges_container = $VBoxContainer/ChallengesContainer
	
	# Load challenges
	refresh_challenges_display()

func refresh_challenges_display():
	# Clear existing challenge displays
	for child in challenges_container.get_children():
		if child.name != "Title":
			child.queue_free()
	
	# Get active challenges
	var challenges = challenge_manager.get_active_challenges()
	
	# Create challenge displays
	for challenge in challenges:
		var challenge_ui = create_challenge_ui(challenge)
		challenges_container.add_child(challenge_ui)

func create_challenge_ui(challenge) -> Control:
	var panel = Panel.new()
	panel.rect_min_size = Vector2(460, 120)
	
	var vbox = VBoxContainer.new()
	vbox.rect_min_size = Vector2(460, 120)
	vbox.margin_left = 10
	vbox.margin_top = 10
	vbox.margin_right = 10
	vbox.margin_bottom = 10
	
	# Challenge title
	var title = Label.new()
	title.text = challenge.title
	title.add_font_override("font", load("res://assets/fonts/vcr.ttf"))
	title.rect_min_size = Vector2(440, 25)
	
	# Challenge description
	var desc = Label.new()
	desc.text = challenge.description
	desc.add_font_override("font", load("res://assets/fonts/vcr.ttf"))
	desc.rect_min_size = Vector2(440, 20)
	desc.modulate = Color(0.8, 0.8, 0.8)
	
	# Progress bar
	var progress_bar = ProgressBar.new()
	progress_bar.rect_min_size = Vector2(440, 20)
	progress_bar.max_value = 100
	progress_bar.value = challenge.get_progress_percentage()
	
	# Progress text
	var progress_text = Label.new()
	progress_text.text = str(challenge.current_progress) + "/" + str(challenge.target_value)
	progress_text.add_font_override("font", load("res://assets/fonts/vcr.ttf"))
	progress_text.rect_min_size = Vector2(440, 20)
	progress_text.align = Label.ALIGN_CENTER
	
	# Reward info
	var reward_text = Label.new()
	reward_text.text = "Reward: " + str(challenge.reward_amount) + " " + ChallengeData.get_reward_type_name(challenge.reward_type)
	reward_text.add_font_override("font", load("res://assets/fonts/vcr.ttf"))
	reward_text.rect_min_size = Vector2(440, 20)
	reward_text.modulate = Color(1, 0.8, 0)
	
	# Claim button (if completed)
	if challenge.is_completed and not challenge.is_claimed:
		var claim_btn = Button.new()
		claim_btn.text = "Claim"
		claim_btn.rect_min_size = Vector2(100, 30)
		claim_btn.connect("pressed", self, "_on_claim_pressed", [challenge.id])
		vbox.add_child(claim_btn)
	elif challenge.is_claimed:
		var claimed_label = Label.new()
		claimed_label.text = "✓ Claimed"
		claimed_label.add_font_override("font", load("res://assets/fonts/vcr.ttf"))
		claimed_label.rect_min_size = Vector2(440, 20)
		claimed_label.modulate = Color(0, 1, 0)
		vbox.add_child(claimed_label)
	
	# Add all elements
	vbox.add_child(title)
	vbox.add_child(desc)
	vbox.add_child(progress_bar)
	vbox.add_child(progress_text)
	vbox.add_child(reward_text)
	
	panel.add_child(vbox)
	return panel

func _on_claim_pressed(challenge_id):
	if challenge_manager.claim_challenge_reward(challenge_id):
		refresh_challenges_display()

func _on_challenges_updated():
	refresh_challenges_display()

func _on_CloseButton_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
