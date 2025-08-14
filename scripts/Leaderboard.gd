extends Control

onready var score_container = $CenterContainer/Panel/VBoxContainer/ScoreContainer
onready var loading_label = $CenterContainer/Panel/VBoxContainer/LoadingLabel
onready var back_button = $CenterContainer/Panel/VBoxContainer/BackButton

var score_item_scene = preload("res://addons/silent_wolf/Scores/ScoreItem.tscn")

func _ready():
	back_button.connect("pressed", self, "_on_BackButton_pressed")
	_load_scores()

func _load_scores():
	loading_label.show()
	score_container.hide()
	
	# Load scores from SilentWolf
	var sw_result = yield(SilentWolf.Scores.get_high_scores(), "sw_scores_received")
	
	loading_label.hide()
	score_container.show()
	
	# Clear existing scores
	for child in score_container.get_children():
		child.queue_free()
	
	# Check if we got scores
	if !sw_result or !sw_result.scores:
		var label = Label.new()
		label.text = "No scores yet!"
		label.align = Label.ALIGN_CENTER
		score_container.add_child(label)
		return
	
	# Add scores to the container
	var position = 1
	for score in sw_result.scores:
		var score_item = score_item_scene.instance()
		score_container.add_child(score_item)
		score_item.get_node("PlayerName").text = str(position) + ". " + score.player_name
		score_item.get_node("Score").text = str(score.score)
		position += 1
		
		# Only show top 10 scores
		if position > 10:
			break

func _on_BackButton_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
