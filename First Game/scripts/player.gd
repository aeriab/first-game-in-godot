extends CharacterBody2D

@export var box_scene: PackedScene
const SPAWN_OFFSET_Y = 0.0

const SPEED = 80.0
const JUMP_VELOCITY = -300.0
var was_on_floor: bool = false

var can_spawn_box: bool = true
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var area_2d = $Area2D
@onready var coyote_timer = $CoyoteTimer

func _physics_process(delta):
	if Input.is_action_just_pressed("spawn_box") && can_spawn_box && custom_on_ground():
		can_spawn_box = false
		spawn_box()
	if Input.is_action_pressed("down"):
		set_collision_layer_value(2, false)
		set_collision_mask_value(2, false)
	else:
		set_collision_layer_value(2, true)
		set_collision_mask_value(2, true)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if !custom_on_ground() && was_on_floor:
		coyote_timer.start()
	
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (custom_on_ground() || !coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		coyote_timer.stop()
		was_on_floor = false
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if custom_on_ground():
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
	was_on_floor = custom_on_ground()

func spawn_box():
	var box_instance = box_scene.instantiate()
	box_instance.scale.y = 0
	box_instance.global_position = self.global_position + Vector2(0, SPAWN_OFFSET_Y)
	get_parent().add_child(box_instance)
	#position.y -= 16.0

func custom_on_ground() -> bool:
	return (area_2d.get_overlapping_bodies().size() > 1) || is_on_floor()
