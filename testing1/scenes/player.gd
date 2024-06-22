extends CharacterBody2D
var dir=Vector2(0,0)

const speed = 20

# Get the gravity from the project settings to be synced with RigidBody nodes.


func _physics_process(delta):
	velocity=dir*speed
	move_and_slide()
func _input(event):
	
	if event is InputEventKey:
		if event.pressed and event.keycode==KEY_UP and dir.y>-2:
			dir.y-=1
		elif event.keycode==KEY_DOWN and dir.y<2:
			dir.y+=1
		elif event.keycode==KEY_RIGHT and dir.x<2:
			dir.x+=1
		elif event.keycode==KEY_LEFT and dir.x>-2:
			dir.x-=1
