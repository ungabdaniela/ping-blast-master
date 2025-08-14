extends Control

func _ready():
	if OS.get_name() == "HTML5" or OS.get_name() == "Android": #Cache le bouton pour changer l'arrière-plan sur Android et Web
		$CustomizeButton.disabled = true
	if OS.get_name() == "Android":
		$FullScreenButton.disabled = true

#Active/Désactive le plein écran
func _on_FullScreenButton_pressed():
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED

#Bouton pour changer l'arrière-plan du jeu
func _on_CustomizeButton_pressed():
	$FileDialog.popup()

func _on_FileDialog_file_selected(path):
	Global.bg_changed = true
	Global.bg_path = path

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
