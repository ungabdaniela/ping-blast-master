extends Control

var score = 0
var score_to_next_level = 5000

signal switch_bg

#Charge le high score
func _ready():
	$HighScoreValue.text = String(Global.highscore)

#Ajoute 10 points quand une boule est touchée :lenny:
func _on_Ball_add_score():
	score += 10
	$ScoreValue.text = String(score) #Actualise le compteur de pièces
	
	#Change l'arrière-plan quand le score est à chaque multiple de 5000
	if score >= score_to_next_level and !Global.bg_changed:
		change_background()
		score_to_next_level += 5000

func scorebonus():
	score += 90
	_on_Ball_add_score()

func get_score():
	return score

#Met en pause le jeu quand la touche [ÉCHAP] est pressée
func _physics_process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			$Sprite.show()
		else:
			$Sprite.hide()
	$ProgressBar.value = $ProgressBar/BonusTimer.time_left * 10

func change_background():
	emit_signal("switch_bg")

func start_bonus_timer_hud():
	$ProgressBar.show()
	$ProgressBar/BonusTimer.start()

func _on_BonusTimer_timeout():
	$ProgressBar.hide()

func _notification(what: int) -> void:
	match what:
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
			# Handle Android back button
			handle_back_button()

func handle_back_button():
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		$Sprite.show()
	else:
		$Sprite.hide()
