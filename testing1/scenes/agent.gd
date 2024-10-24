extends CharacterBody2D
@onready var nav_agent = $NavigationAgent2D
@onready var player = $"../player"
@onready var timer = $Timer
@onready var manager = $".."
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

const speed=20
#shortcut for tasks that I use often
const wait_1h={"type":"wait","max_duration":1}
var goto_work={"type":"goto","min_distance":25,"coords":Vector2(0,0),"max_duration":10,"destination_type":"building"}
#variable individual's data
var destination_type="building"
var id=0
var workplace=0
var workplace_coords=Vector2(25,25)
var age=0
var domicile=0
var domicile_coords=Vector2(0,0)
var wallet=0
var destination=Vector2(15,15)
var variant=0
var task_file=[]
var current_task={"type":"wait","max_duration":2}
var min_distance_to_destination=25
var current_task_duration=0
var job="none"
var work_task={"type":"work_factory","stop_time":17,"subtasks_loop":[goto_work,wait_1h]}
var formation=["worker","farmer","retailer"]
func clear_current_task():
	current_task_duration=0
	if len(task_file)==0:
		task_file.append(goto_work)
		task_file.append({"type":"wait","max_duration":2})
	current_task=task_file[0]
	task_file.remove_at(0)
func reset_task_file():
	task_file=[]
	


func process_task():
	if current_task["type"]=="goto":
		destination=current_task["coords"]
		destination_type=current_task["destination_type"]
		min_distance_to_destination=current_task["min_distance"]
		if is_task_completed():
			clear_current_task()
		
	elif current_task["type"]=="wait":
		if is_task_completed():
			clear_current_task()
	elif current_task["type"]=="work_factory":		
		if is_task_completed():
			clear_current_task()
		else:	
			for i in range(current_task["subtasks_loop"].size()):
				task_file.insert(i,current_task["subtasks_loop"][i])
			task_file.insert(current_task["subtasks_loop"].size(),current_task)#its a loop
			clear_current_task()
			process_task()
		
		
func is_task_completed():
	if current_task["type"]=="goto":
		if distance(position,destination)<current_task["min_distance"] or current_task_duration>current_task["max_duration"]:	
			return true
		else:
			return false
	elif current_task["type"]=="work_factory":
		if manager.date["hour"]>=current_task["stop_time"]:
			return true
		else:
			return false
	elif current_task["type"]=="wait":
		if current_task_duration>=current_task["max_duration"]:
			return true
		else:
			return false
func get_data()->Dictionary:
	return {"id":id,"workplace":workplace,"workplace_coords":workplace_coords ,"age":age,"domicile":domicile,"domicile_coords":domicile_coords , "wallet":wallet,"position":position,"destination":destination,"variant":variant,
	"task_file":task_file,"current_task":current_task,"current_task_duration":current_task_duration,"goto_work":goto_work,"work_task":work_task,
	"job":job,"formation":formation}
func set_data(data:Dictionary):
	id=data["id"]
	workplace=data["workplace"]
	workplace_coords=data["workplace_coords"]
	age=data["age"]
	domicile=data["domicile"]
	domicile_coords=data["domicile_coords"]
	wallet=data["wallet"]
	destination=data["destination"]
	variant=data["variant"]
	animated_sprite_2d.frame=variant
	position=data["position"]
	task_file=data["task_file"]
	current_task=data["current_task"]
	current_task_duration=data["current_task_duration"]
	goto_work=data["goto_work"]
	work_task=data["work_task"]
	job=data["job"]
	formation=data["formation"]
func distance(a:Vector2,b:Vector2)->float:
	return sqrt((a.x-b.x)**2+(a.y-b.y)**2)
func _physics_process(delta):
	var dir=to_local(nav_agent.get_next_path_position()).normalized()
	velocity=dir*speed
	move_and_slide()
	if distance(position,destination)<min_distance_to_destination and destination_type=="building":
		visible=false
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
	process_task()
	current_task_duration+=1
	if manager.date["weekday"]==5 or manager.date["weekday"]==6:#5 for saturday and 6 for monday
		print("weekend?")
	else:
		if manager.date["hour"]==7:		
			print("workplace coords : "+str(workplace_coords))
			task_file.append(work_task)
	make_path(destination)
	#debug to check the coords of workplace
	#print("[*]destination of "+str(id)+": "+str(destination))
	#print("[*]domicile of "+str(id)+": "+str(domicile_coords))
	
func define_domicile(houses_table):
	var sorted_table=manager.get_nearest_building(houses_table,workplace_coords*16)
	for i in range(sorted_table.size()):
		if sorted_table[i]["inhabitants"]==[]:
			print("[*] "+str(id)+" found a new home : "+str(houses_table[i]["id"]))
			houses_table[manager.get_element_index(sorted_table[i]["id"],houses_table)]["inhabitants"].append(id)
			domicile=sorted_table[i]["id"]
			domicile_coords=sorted_table[i]["coords"]
			print(domicile_coords)
			return 0

func define_workplace(workplace_table):
	for i in range(workplace_table.size()):
		var jobs_available=get_jobs_available(workplace_table[i])
		print(jobs_available)
		if jobs_available!=[]:
			for ajob in jobs_available:
				if formation.has(ajob):
					print("I should have a fucking job")
					workplace_table[i]["employees"].append({"id":id,"job":ajob})
					workplace=workplace_table[i]["id"]
					workplace_coords=workplace_table[i]["coords"]
					
					
					if workplace_table[i]["type"]=="factory":
						goto_work["coords"]=workplace_coords*16#workplace and domicile coords are for the building grids, every tile is 16x16
						work_task={"type":"work_factory","stop_time":17,"subtasks_loop":[goto_work,wait_1h]}
					
					elif workplace_table[i]["type"]=="farm":
						goto_work["coords"]=workplace_coords*16
						goto_work["destination_type"]="outside"
						work_task={"type":"work_factory","stop_time":17,"subtasks_loop":[goto_work,wait_1h]}
					print("[*] "+str(id)+" found a new work : "+str(workplace_table[i]["id"]))
					break
			
	
	return 0
			
func update_workplace(workplace_table):
	if workplace_coords==Vector2(0,0) or manager.get_element_index(workplace,manager.workplaces)==-1:#if no workplace or worplace deleted
		define_workplace(workplace_table)
func update_domicile(houses_table):
	if domicile_coords==Vector2(0,0) or manager.get_element_index(domicile,manager.houses)==-1:
		define_domicile(houses_table)

func _ready():
	define_workplace(manager.workplaces)
	define_domicile(manager.houses)
	variant=randi_range(0,3)
	animated_sprite_2d.frame=variant
func get_jobs_dict(employees):
	var jobs_list=[]
	var jobs_dict={}
	
	for i in employees:
		jobs_list.append(i["job"])
	for i in jobs_list:
		if jobs_dict.has(i):
			jobs_dict[i]+=1
		else:
			jobs_dict[i]=0
	return jobs_dict
func get_substract_list(dict1,dict2):#returns a list with a key for dict1 for each value in the difference between its value with dict2
	var thelist=[]
	for i in dict1:
		if dict2.has(i):
			for j in range(dict1[i]-dict2[i]):
				thelist.append(i)
		else:
			for j in range(dict1[i]):
				thelist.append(i)
	return thelist
func get_jobs_available(workplace):
	var jobs_list=get_jobs_dict(workplace["employees"])
	return get_substract_list(workplace["employee_needs"],jobs_list)
