extends Control

# Required class references
const Global = preload("res://scripts/Global.gd")

# Node references
onready var username_input = $CenterContainer/SignUpPanel/VBoxContainer/Username
onready var email_input = $CenterContainer/SignUpPanel/VBoxContainer/Email
onready var password_input = $CenterContainer/SignUpPanel/VBoxContainer/Password
onready var confirm_password_input = $CenterContainer/SignUpPanel/VBoxContainer/ConfirmPassword
onready var error_label = $CenterContainer/SignUpPanel/VBoxContainer/ErrorLabel
onready var signup_button = $CenterContainer/SignUpPanel/VBoxContainer/SignUpButton
onready var back_button = $CenterContainer/SignUpPanel/VBoxContainer/BackToLogin

const SAVE_FILE = "user://player_credentials.json"
const EMAIL_FILE = "user://player_emails.json"

func _ready():
	# Clear any previous error messages
	error_label.text = ""
	
	# Connect button signals
	signup_button.connect("pressed", self, "_on_SignUpButton_pressed")
	back_button.connect("pressed", self, "_on_BackToLogin_pressed")
	
	# Initialize files if they don't exist
	create_files_if_not_exist()

func _on_SignUpButton_pressed():
	var username = username_input.text
	var email = email_input.text
	var password = password_input.text
	var confirm_password = confirm_password_input.text
	
	# Clear previous error message
	error_label.text = ""
	
	# Basic validation
	if username.empty() or email.empty() or password.empty() or confirm_password.empty():
		error_label.text = "Please fill in all fields"
		return
	
	if password != confirm_password:
		error_label.text = "Passwords do not match"
		return
	
	if len(password) < 6:
		error_label.text = "Password must be at least 6 characters"
		return
	
	if not validate_email(email):
		return
	
	# Check if username already exists
	if user_exists(username):
		error_label.text = "Username already taken"
		return
	
	# Save credentials and create account
	save_user_data(username, password, email)
	
	# Update global state
	Global.player_name = username
	save_player_name(username)
	
	error_label.text = "Account created successfully!"
	
	# Wait a moment then try to load main menu
	yield(get_tree().create_timer(1.0), "timeout")
	var err = get_tree().change_scene("res://scenes/MainMenu.tscn")
	if err != OK:
		error_label.text = "Error loading main menu. Please try again."

func _on_BackToLogin_pressed():
	get_tree().change_scene("res://scenes/Login.tscn")

func user_exists(username: String) -> bool:
	var file = File.new()
	if not file.file_exists(SAVE_FILE):
		return false
	
	file.open(SAVE_FILE, File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	
	return data != null and username in data

func save_user_data(username: String, password: String, email: String) -> void:
	# Save credentials
	var cred_file = File.new()
	var cred_data = {}
	
	if cred_file.file_exists(SAVE_FILE):
		cred_file.open(SAVE_FILE, File.READ)
		cred_data = parse_json(cred_file.get_as_text())
		cred_file.close()
	
	cred_data[username] = password
	
	cred_file.open(SAVE_FILE, File.WRITE)
	cred_file.store_string(JSON.print(cred_data))
	cred_file.close()
	
	# Save email
	var email_file = File.new()
	var email_data = {}
	
	if email_file.file_exists(EMAIL_FILE):
		email_file.open(EMAIL_FILE, File.READ)
		email_data = parse_json(email_file.get_as_text())
		email_file.close()
	
	email_data[username] = email
	
	email_file.open(EMAIL_FILE, File.WRITE)
	email_file.store_string(JSON.print(email_data))
	email_file.close()

func save_player_name(player_name: String) -> void:
	var save_file = File.new()
	var game_data = {
		"player_name": player_name
	}
	save_file.open("user://playername.json", File.WRITE)
	save_file.store_string(JSON.print(game_data))
	save_file.close()

func validate_email(email: String) -> bool:
	if not "@" in email:
		error_label.text = "Please enter a valid email"
		return false
	return true

func create_files_if_not_exist() -> void:
	var file = File.new()
	
	# Create credentials file
	if not file.file_exists(SAVE_FILE):
		file.open(SAVE_FILE, File.WRITE)
		file.store_string("{}")
		file.close()
	
	# Create email file
	if not file.file_exists(EMAIL_FILE):
		file.open(EMAIL_FILE, File.WRITE)
		file.store_string("{}")
		file.close()
	
	# Create player name file
	if not file.file_exists("user://playername.json"):
		file.open("user://playername.json", File.WRITE)
		file.store_string("{}")
		file.close()

func create_account(username: String, email: String) -> void:
	Global.player_name = username
	save_player_name(username)
	error_label.text = "Account created successfully!"
	
	# Save everything before scene transition
	save_user_data(username, password_input.text, email)
	
	# Wait a bit before switching scenes
	yield(get_tree().create_timer(1.0), "timeout")
	
	# Try to load MainMenu scene
	var scene = load("res://scenes/MainMenu.tscn")
	if scene:
		get_tree().change_scene_to(scene)
	else:
		error_label.text = "Error loading main menu"
