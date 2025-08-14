extends KinematicBody2D

var invincible

signal lose
signal multibullet
signal multibullet_stop

#Suit le mouvement de la souris sur l'axe X
func _on_Move_timeout():
	var tween = get_node("Tween")
	tween.interpolate_property(self, "position",Vector2(position.x,position.y), Vector2(get_viewport().get_mouse_position().x,position.y),0.05 ,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

#Quand le carré rouge touche une balle, la partie est perdue
func _on_Area2D_area_entered(area):
	if !invincible:
		emit_signal("lose")
		queue_free()

func bonus():
	randomize() #Initialise le générateur de nombre aléatoire
	var percent = randf()
	if (percent > 0.5):
		invincible = true
		modulate = Color(1,1,1,0.25)
		$Invinciblility.start()
		$InvinciblilityGet.play()
	else:
		emit_signal("multibullet")
		$MultiBullet.start()
		$InvinciblilityGet.play()
	get_node("../CanvasLayer/HUD").start_bonus_timer_hud()

func _on_Invinciblility_timeout():
	invincible = false
	modulate = Color(1,1,1,1)

func _on_MultiBullet_timeout():
	emit_signal("multibullet_stop")
