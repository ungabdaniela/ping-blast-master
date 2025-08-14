extends Control

func _ready():
	load_highscore() #Charge le meilleur score
	if Global.player_name == "Anonymous":
		load_playername()
	if !Global.leaderboard_enabled:
		$LeaderboardButton.queue_free()
	if Global.tate_mode:
		$TateButton.text = "TITLE_MODE_TATE"
		DisplayServer.screen_set_orientation(0)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1280, 720))

#Bouton pour jouer au jeu
func _on_PlayButton_pressed():
	if Global.tate_mode:
		get_tree().change_scene_to_file("res://scenes/Game_tate.tscn")
		DisplayServer.screen_set_orientation(1)
	else:
		get_tree().change_scene_to_file("res://scenes/Game.tscn")

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
	var test_json_conv = JSON.new()
	test_json_conv.parse(json_str).result
	var game_data = test_json_conv.get_data()
	Global.highscore = game_data.highscore #Met la première ligne du fichier dans une variable "highscore"
	$TopValue.text = String(Global.highscore) #Change le texte
	save_file.close() #Ferme le fichier

func load_playername():
	var save_file = File.new()
	if not save_file.file_exists("user://playername.json"):
		return #Ne fait rien si le fichier n'existe pas

	save_file.open("user://playername.json", File.READ) #Ouvre le fichier
	var json_str = save_file.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(json_str).result
	var game_data = test_json_conv.get_data()
	Global.player_name = game_data.player_name #Met la première ligne du fichier dans une variable "player_name"
	save_file.close() #Ferme le fichier

func _on_SettingsButton_pressed():
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_LeaderboardButton_pressed():
	get_tree().change_scene_to_file("res://addons/silent_wolf/Scores/Leaderboard.tscn")

func _on_TateButton_toggled(button_pressed):
	if Global.tate_mode:
		Global.tate_mode = false
		$TateButton.text = "TITLE_MODE_NORMAL"
	else:
		Global.tate_mode = true
		$TateButton.text = "TITLE_MODE_TATE"
