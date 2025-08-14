extends Control

onready var username = $Username
onready var password = $Password
onready var login_button = $LoginButton
onready var error_label = $ErrorLabel

func _ready():
    login_button.connect("pressed", self, "_on_login_pressed")

func _on_login_pressed():
    var user = username.text
    var pass = password.text
    # Replace with actual authentication logic
    var auth = get_node("/root/SilentWolf/Auth/Login")
    auth.login(user, pass)
    # Show error if login fails (implement callback)
