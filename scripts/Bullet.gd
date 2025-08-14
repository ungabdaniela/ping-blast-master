extends KinematicBody2D

const speed = 700 #Vitesse
var velocity = Vector2()

#Téléporte la balle vers le joueur (carré rouge)
func _ready():
	set_position(get_node("/root/Game/Player").get_position() - Vector2(0, 50))

#La balle se déplace vers le haut
func _physics_process(delta):
	velocity.y = -speed
	velocity = move_and_slide(velocity)

#Libère la balle de la RAM quand elle est tout en haut
func _on_Timer_timeout():
	queue_free()

#Libère la balle de la RAM quand elle touche une boule :lenny:
func _on_Area2D_body_entered(body):
	body.hit()
	queue_free()
