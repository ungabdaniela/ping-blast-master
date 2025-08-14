extends Control

onready var scores_list = $CenterContainer/Panel/VBoxContainer/ScrollContainer/ScoresList
onready var back_button = $CenterContainer/Panel/VBoxContainer/BackButton

func _ready():
	back_button.connect("pressed", self, "_on_BackButton_pressed")
	_load_scores()

func _load_scores():
	# Clear existing scores
	for child in scores_list.get_children():
		child.queue_free()
	
	var scores = ScoresManager.load_scores()
	var position = 1
	
	for score_data in scores:
		var score_item = _create_score_item(position, score_data.player_name, score_data.score)
		scores_list.add_child(score_item)
		position += 1

func _create_score_item(position: int, player_name: String, score: int) -> HBoxContainer:
	var item = HBoxContainer.new()
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var rank_label = Label.new()
	rank_label.text = str(position) + "."
	rank_label.rect_min_size = Vector2(50, 0)
	
	var name_label = Label.new()
	name_label.text = player_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var score_label = Label.new()
	score_label.text = str(score)
	score_label.align = Label.ALIGN_RIGHT
	score_label.rect_min_size = Vector2(100, 0)
	
	# Add labels to the item
	item.add_child(rank_label)
	item.add_child(name_label)
	item.add_child(score_label)
	
	# Set up the fonts
	var font = load_font()
	rank_label.add_font_override("font", font)
	name_label.add_font_override("font", font)
	score_label.add_font_override("font", font)
	
	return item

func load_font() -> DynamicFont:
	var font = DynamicFont.new()
	font.font_data = load("res://assets/fonts/vcr.ttf")
	font.size = 24
	return font

func _on_BackButton_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
