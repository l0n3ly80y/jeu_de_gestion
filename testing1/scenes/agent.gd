extends CharacterBody2D
@onready var nav_agent = $NavigationAgent2D
@onready var player = $"../player"
@onready var timer = $Timer
@onready var manager = $".."
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

const speed=20
#variable individual's data
var id=0
var workplace=0
var workplace_coords=Vector2(0,0)
var age=0
var domicile=0
var domicile_coords=Vector2(0,0)
var wallet
var destination=Vector2(15,15)

func get_data()->Dictionary:
	return {"id":id,"workplace":workplace,"age":age,"domicile":domicile,"wallet":wallet}
func distance(a:Vector2,b:Vector2)->float:
	return sqrt((a.x-b.x)**2+(a.y-b.y)**2)
func _physics_process(delta):
	var dir=to_local(nav_agent.get_next_path_position()).normalized()
	velocity=dir*speed
	move_and_slide()
	if distance(position,destination)<25:
		visible=false
		destination=position
		collision_shape_2d.disabled=true
	else:
		visible=true
		collision_shape_2d.disabled=false
func make_path(target)->void:
	nav_agent.target_position= target

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode==KEY_M:
			position=get_global_mouse_position()

func _on_timer_timeout():
	if manager.date["hour"]<16 and manager.date["hour"]>7:
		destination=workplace_coords*16
	else:
		destination=domicile_coords*16
	#debug to check the coords of workplace
	#print("[*]destination of "+str(id)+": "+str(destination))
	#print("[*]domicile of "+str(id)+": "+str(domicile_coords))
	
	make_path(destination)
func define_domicile(houses_table):
	for i in range(houses_table.size()):
		if houses_table[i]["inhabitants"]==[]:
			print("found")
			houses_table[i]["inhabitants"].append(id)
			domicile=houses_table[i]["id"]
			domicile_coords=houses_table[i]["coords"]
			print(domicile_coords)
			return 0

func define_workplace(workplace_table):
	for i in range(workplace_table.size()):
		if workplace_table[i]["employees"].size()<5:
			print("[*]found a job")
			workplace_table[i]["employees"].append(id)
			workplace=workplace_table[i]["id"]
			workplace_coords=workplace_table[i]["coords"]
			return 0
			
func update_workplace(workplace_table):
	if workplace_coords==Vector2(0,0) or manager.get_element_index(domicile,workplace_table)==-1:#if no workplace or worplace deleted
		print("new work")
		define_workplace(workplace_table)
func update_domicile(houses_table):
	if domicile_coords==Vector2(0,0) or manager.get_element_index(domicile,houses_table)==-1:
		define_domicile(houses_table)

	
func _ready():
	define_domicile(manager.houses)
	define_workplace(manager.workplaces)
	animated_sprite_2d.frame=randi_range(0,3)
