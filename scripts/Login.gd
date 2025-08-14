extends Control

onready var username_input = $CenterContainer/LoginPanel/VBoxContainer/Username
onready var password_input = $CenterContainer/LoginPanel/VBoxContainer/Password
onready var error_label = $CenterContainer/LoginPanel/VBoxContainer/ErrorLabel
onready var login_button = $CenterContainer/LoginPanel/VBoxContainer/LoginButton
onready var register_button = $CenterContainer/LoginPanel/VBoxContainer/RegisterPrompt/RegisterButton

const SAVE_FILE = "user://player_credentials.json"

func _ready():
	error_label.text = ""
	
	# Connect button signals
	login_button.connect("pressed", self, "_on_LoginButton_pressed")
	register_button.connect("pressed", self, "_on_RegisterButton_pressed")
	
	# Create credentials file if it doesn't exist
	var file = File.new()
	if not file.file_exists(SAVE_FILE):
		file.open(SAVE_FILE, File.WRITE)
		file.store_string("{}")
		file.close()

func _on_LoginButton_pressed():
	var username = username_input.text
	var password = password_input.text
	
	if username.empty() or password.empty():
		error_label.text = "Please enter both username and password"
		return
	
	# Simple local authentication - no need for "Logging in..." message for local auth
	if verify_credentials(username, password):
		Global.player_name = username
		save_player_name(username)
		get_tree().change_scene("res://scenes/MainMenu.tscn")
	else:
		error_label.text = "Invalid username or password"

func _on_RegisterButton_pressed():
	get_tree().change_scene("res://scenes/SignUp.tscn")

func verify_credentials(username: String, password: String) -> bool:
	var file = File.new()
	if not file.file_exists(SAVE_FILE):
		error_label.text = "No credentials file found. Please sign up first."
		return false
	
	if file.open(SAVE_FILE, File.READ) != OK:
		error_label.text = "Error reading credentials"
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var data = parse_json(content)
	if typeof(data) != TYPE_DICTIONARY:
		error_label.text = "Invalid credentials file format"
		return false
		
	if not username in data:
		error_label.text = "Username not found"
		return false
		
	if data[username] != password:
		error_label.text = "Invalid password"
		return false
		
	return true

func save_credentials(username: String, password: String) -> void:
	var file = File.new()
	var data = {}
	
	if file.file_exists(SAVE_FILE):
		file.open(SAVE_FILE, File.READ)
		data = parse_json(file.get_as_text())
		file.close()
	
	data[username] = password
	
	file.open(SAVE_FILE, File.WRITE)
	file.store_string(JSON.print(data))
	file.close()

func save_player_name(player_name: String):
	var save_file = File.new()
	var game_data = {
		"player_name": player_name
	}
	save_file.open("user://playername.json", File.WRITE)
	save_file.store_line(JSON.print(game_data))
	save_file.close()
