extends CharacterBody2D
var dir=Vector2(0,0)

const speed = 20

# Get the gravity from the project settings to be synced with RigidBody nodes.


func _physics_process(delta):
	velocity=dir*speed
	move_and_slide()
	var is_moving_horizontal=false
	var is_moving_vertical=false
	if Input.is_action_pressed("ui_down"):
		dir.y=2
		is_moving_vertical=true
	elif Input.is_action_pressed("ui_up"):
		dir.y=-2
		is_moving_vertical=true
		
	if Input.is_action_pressed("ui_left"):
		dir.x=-2
		is_moving_horizontal=true
		
	elif Input.is_action_pressed("ui_right"):
		dir.x=2
		is_moving_horizontal=true
	if !is_moving_vertical:
		dir.y=0
	if !is_moving_horizontal:
		dir.x=0		


