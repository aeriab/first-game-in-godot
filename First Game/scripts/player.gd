extends CharacterBody2D

@export var box_scene: PackedScene
const SPAWN_OFFSET_Y = 0.0

const SPEED = 80.0
const JUMP_VELOCITY = -190.0

var can_spawn_box: bool = true
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	if Input.is_action_just_pressed("spawn_box") && can_spawn_box:
		can_spawn_box = false
		spawn_box()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()


func spawn_box():
	if is_on_floor():
		var box_instance = box_scene.instantiate()
		box_instance.global_position = self.global_position + Vector2(0, SPAWN_OFFSET_Y)
		get_parent().add_child(box_instance)
		#position.y -= 16.0
