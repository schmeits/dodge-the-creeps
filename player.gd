class_name Player extends Area2D

@export var speed = 400 # How fast the player will move (pixels/sec).

const BULLET_VELOCITY = 850.0
const BULLET_SCENE = preload("res://bullet.tscn")

var screen_size # Size of the game window.
var lastvelocity = Vector2.ZERO

signal hit

@onready var timer := $CooldownTimer as Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	$CollisionShape2D.disabled = true
	hide()

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.x !=0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.rotation = deg_to_rad(270) if velocity.x < 0 else deg_to_rad(90)
	elif velocity.y !=0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.rotation = deg_to_rad(180) if velocity.y > 0 else deg_to_rad(0)
		
	# uncomment this if you want to reset position if nothing is pressed
	#else:
		#$AnimatedSprite2D.rotation = deg_to_rad(0)
		
	if velocity.x !=0 && velocity.y != 0 && velocity.y > 0 && velocity.x < 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.rotation = deg_to_rad(225)
	elif velocity.x !=0 && velocity.y != 0 && velocity.y > 0 && velocity.x > 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.rotation = deg_to_rad(135)
	elif velocity.x !=0 && velocity.y != 0 && velocity.y < 0 && velocity.x > 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.rotation = deg_to_rad(45) 
	elif velocity.x !=0 && velocity.y != 0 && velocity.y < 0 && velocity.x < 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.rotation = deg_to_rad(315)

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		lastvelocity = velocity
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	if Input.is_action_pressed("shoot") && !$CollisionShape2D.disabled:
		shoot(lastvelocity)
		
	# make sure it does not exit the screen
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func _on_body_entered(_body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func shoot(velocity: Vector2) -> bool:
	
	if not timer.is_stopped():
		return false
	
	var bullet := BULLET_SCENE.instantiate() as Bullet
	bullet.global_position = global_position

	# Normalize the direction vector (optional, if you need a unit vector)
	velocity = velocity.normalized()
	
	# You can then use this direction vector to move the bullet
	# For example, assuming bullet_speed is the speed of the bullet:
	var bullet_velocity = velocity * BULLET_VELOCITY
	bullet.linear_velocity = bullet_velocity
	
	bullet.set_as_top_level(true)

	get_node('/root').add_child(bullet)
	
	timer.start()
	
	return true
