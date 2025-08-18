extends Control

func _ready():
	load_highscore()
	if Global.player_name == "Anonymous":
		load_playername()
	
	# Update the player name display
	if has_node("UserLabel"):
		$UserLabel.text = "Player: " + Global.player_name
	
	# Connect all buttons
	var buttons = {
		"VBoxContainer/PlayButton": "_on_PlayButton_pressed",
		"VBoxContainer/LeaderboardButton": "_on_LeaderboardButton_pressed",
		"VBoxContainer/ChallengesButton": "_on_ChallengesButton_pressed",
		"VBoxContainer/SettingsButton": "_on_SettingsButton_pressed",
		"VBoxContainer/QuitButton": "_on_QuitButton_pressed"
	}
	
	for path in buttons:
		if has_node(path):
			var button = get_node(path)
			if !button.is_connected("pressed", self, buttons[path]):
				button.connect("pressed", self, buttons[path])

#Bouton pour jouer au jeu
func _on_PlayButton_pressed():
	if Global.tate_mode:
		get_tree().change_scene("res://scenes/Game_tate.tscn")
		OS.set_screen_orientation(1)
	else:
		get_tree().change_scene("res://scenes/Game.tscn")

#Bouton pour quitter le jeu
func _on_QuitButton_pressed():
	get_tree().quit()

#Cette fonction charge les meilleurs temps
#Sous GNU/Linux le fichier se situe dans /home/$USER/.local/share/godot/app_userdata/Ping Blast/
func load_highscore():
	var save_file = File.new()
	if not save_file.file_exists("user://highscores.json"):
		return #Ne fait rien si le fichier n'existe pas

	save_file.open("user://highscores.json", File.READ) #Ouvre le fichier
	var json_str = save_file.get_as_text()
	var game_data = JSON.parse(json_str).result
	Global.highscore = game_data.highscore #Met la première ligne du fichier dans une variable "highscore"
	$TopValue.text = String(Global.highscore) #Change le texte
	save_file.close() #Ferme le fichier

func load_playername():
	var save_file = File.new()
	if not save_file.file_exists("user://playername.json"):
		return #Ne fait rien si le fichier n'existe pas

	save_file.open("user://playername.json", File.READ) #Ouvre le fichier
	var json_str = save_file.get_as_text()
	var game_data = JSON.parse(json_str).result
	Global.player_name = game_data.player_name #Met la première ligne du fichier dans une variable "player_name"
	save_file.close() #Ferme le fichier

func _on_LeaderboardButton_pressed():
	get_tree().change_scene("res://scenes/LocalLeaderboard.tscn")

func _on_SettingsButton_pressed():
	get_tree().change_scene("res://scenes/Settings.tscn")

func _on_ChallengesButton_pressed():
	get_tree().change_scene("res://scenes/DailyChallenges.tscn")
