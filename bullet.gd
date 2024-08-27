class_name Bullet extends RigidBody2D

func _on_body_entered(body: Node) -> void:
	if body is Mob:
		(body as Mob).queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
