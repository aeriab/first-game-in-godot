extends StaticBody2D

@export var grow_duration: float = 0.1
@onready var player = $"../Player"
@onready var collision_shape_2d = $CollisionShape2D

@onready var solid_block = $SolidBlock
@onready var ghost_block = $GhostBlock


var spring_duration: float = 2.0

var target_position: Vector2

var is_solid: bool = true

var is_first_spring: bool = true

func _ready():
	scale = Vector2(1, 0.001)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, grow_duration)
	

func _physics_process(delta):
	if Input.is_action_just_pressed("spawn_box"):
		if is_solid:
			is_solid = false
			target_position = player.global_position
		else:
			active_tween.kill()
			is_solid = true
			target_position = global_position
			global_position = target_position
	
	if !is_solid && is_first_spring:
		is_first_spring = false
		spring_to_target()
	
	if is_solid:
		collision_shape_2d.disabled = false
		is_first_spring = true
	else:
		collision_shape_2d.disabled = true
	solid_block.visible = is_solid
	ghost_block.visible = !is_solid

var active_tween: Tween
func spring_to_target():
	if active_tween:
		active_tween.kill()
	active_tween = create_tween()
	var overshoot_factor: float = 1.3
	var start_position = global_position
	var final_position = target_position
	var overshoot_position = start_position.lerp(final_position, overshoot_factor)
	
	active_tween.tween_property(self, "global_position", overshoot_position, spring_duration * 0.3)\
			   .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			   
	# Part 2: Move from the overshoot back to the final position.
	active_tween.tween_property(self, "global_position", final_position, spring_duration * 0.3)\
			   .set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
