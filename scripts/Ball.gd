extends KinematicBody2D

var velocity = Vector2(100,0)
var strengh = 50 #Compteur
const GRAVITY = 5 #Gravité
var percent = randf()
var is_bonus

signal add_score
signal spawn_small
signal explode
signal bonus_get

#Couleurs aléatoires (RGB)
const colors = [Color(1.0, 0.0, 0.0), #Rouge
		  Color(0.0, 1.0, 0.0), #Vert
		  Color(0.0, 0.8, 1.0), #Bleu
		  Color(1.0, 0.6, 0.0), #Orange
		  Color(0.7, 0.0, 1.0), #Violet
		  Color(1.0, 1.0, 1.0)] #Blanc

func _ready():
	randomize() #Initialise le générateur de nombre aléatoire
	if is_in_group("ball"):
		connect("spawn_small", get_node(".."), "_on_Ball_spawn_small")
	else:
		strengh = strengh / 2 #Divise le compteur des petites boules par deux
	modulate = colors[randi() % colors.size()] #Change la couleur aléatoirement
	$Strengh.text = String(strengh) #Actualise le compteur
	connect("add_score", get_node("../CanvasLayer/HUD"), "_on_Ball_add_score")
	connect("explode", get_node(".."), "_on_Ball_explode")
	
	if (percent > 0.8) and not is_in_group("ball_small"):
		modulate = Color(1,1,0)
		$Strengh.text = "?"
		strengh = 10
		is_bonus = true
		connect("bonus_get", get_node("../Player"), "bonus")

#Pour faire rebondir
func _physics_process(delta):
	velocity.y += GRAVITY
	move_and_slide(velocity, Vector2.UP)
	if is_on_wall():
		velocity.x *= -1
		$Bounce.play()
	if is_on_floor():
		velocity.y *= -1
		$Bounce.play()
	
	#Disparait quand le compteur est à 0
	if strengh <= 0:
		if is_bonus:
			emit_signal("bonus_get")
		else:
			emit_signal("spawn_small")
		emit_signal("explode")
		queue_free()

#Décrémente le compteur
func hit():
	strengh -= 1
	emit_signal("add_score")
	
	if not is_bonus:
		$Strengh.text = String(strengh) #Actualise le compteur
