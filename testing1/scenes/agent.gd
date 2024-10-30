extends CharacterBody2D
@onready var nav_agent = $NavigationAgent2D
@onready var player = $"../player"
@onready var timer = $Timer
@onready var manager = $".."
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var backpack: Sprite2D = $backpack
@onready var visual_effect: GPUParticles2D = $VisualEffect

const speed=20
const capacity=15
#shortcut for tasks that I use often
const wait_1h={"type":"wait","max_duration":1}
#variable individual's data
var destination_type="building"
var id=69
var workplace=0
var workplace_coords=Vector2(25,25)
var age=0
var domicile=0
var domicile_coords=Vector2(0,0)
var wallet=0
var destination=Vector2(15,15)
var variant=0
var inventory=[]
var task_file=[]
var current_task={"type":"wait","max_duration":2}
var min_distance_to_destination=25
var current_task_duration=0
var job="none"
var goto_work={"type":"goto","min_distance":25,"coords":Vector2(0,0),"max_duration":10,"destination_type":"building"}

var work_task={"type":"work_factory","stop_time":17,"subtasks_loop":[goto_work,wait_1h]}
var formation=["worker","farmer","retailer","shop_deliverer"]
const carrot={"name":"carrot","size":1}
var produce_commodity={"type":"produce","commodity":carrot}
const consume_commodity={"type":"consume","commodity":carrot}
func get_item_index(item,inventory_list):
	for i in range(len(inventory_list)):
		if inventory_list[i]==item:
			return i
	return -1
	
func get_occupied_space(inventory_list):
	var occupied_space=0
	for i in inventory_list:
		occupied_space+=i["size"]
	return occupied_space
func clear_current_task():
	current_task_duration=0
	if len(task_file)==0:
		task_file.append({"type":"goto","min_distance":25,"coords":domicile_coords,"max_duration":10,"destination_type":"building"})
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
	elif current_task["type"]=="produce":
		if capacity-get_occupied_space(inventory)>=current_task["commodity"]["size"]:
			inventory.append(current_task["commodity"])
		clear_current_task()
	elif current_task["type"]=="deposit":
		for i in range(current_task["quantity"]):
			if inventory.has(current_task["commodity"]):
				if manager.add_item_to_building(current_task["commodity"],"workplaces",current_task["target_id"])==1:#if it succeeds
					inventory.remove_at(get_item_index(current_task["commodity"],inventory))
		#task_file.insert(0,wait_1h)
		clear_current_task()
	elif current_task["type"]=="retrieve":
		for i in range(current_task["quantity"]):
			if capacity-get_occupied_space(inventory)>=current_task["commodity"]["size"]:
				if manager.retrieve_item_from_building(current_task["commodity"],"workplaces",current_task["target_id"])==1:
					inventory.append(current_task["commodity"])
		clear_current_task()
	elif current_task["type"]=="consume_commodity":
		if inventory.has(current_task["commodity"]):
			inventory.remove_at(inventory.find(current_task["type"],0))
			visual_effect.emitting=true
		clear_current_task()
	elif current_task["type"]=="leisure":
		for i in range(current_task["subtasks_loop"].size()):
			task_file.insert(i,current_task["subtasks"][i])
		#if current_task["loop"]:
			#task_file.insert(current_task["subtasks"].size(),current_task)#its a loop
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
	"job":job,"formation":formation,
	"inventory":inventory}
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
	inventory=data["inventory"]
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
	visual_effect.emitting=false
	process_task()
	if inventory==[]:
		backpack.visible=false
	else:
		backpack.visible=true
	current_task_duration+=1
	if manager.date["weekday"]==5 or manager.date["weekday"]==6:#5 for saturday and 6 for monday
		var shops=manager.get_nearest_building(manager.get_list_of_type(manager.workplaces,"shop"),position/16)
		if shops!=[]:
			print("[!]gonna have fun")
			task_file.append({"type":"leisure","subtasks":[
	{"type":"goto","min_distance":35,"coords":shops[0]["coords"],"max_duration":10,"destination_type":"outside"},
	{"type":"retrieve","target_id":manager.get_info("workplaces",workplace,"shop")["id"],"commodity":carrot,"quantity":1,"target_table":"workplaces"},
	{"type":"consume","commodity":carrot}
	],"loop":false})
	else:
		if manager.date["hour"]==7:		
			task_file.append(work_task)
	make_path(destination)
	#debug to check the coords of workplace
	#print("[*]destination of "+str(id)+": "+str(destination))
	#print("[*]domicile of "+str(id)+": "+str(domicile_coords))
	
func define_domicile(houses_table):
	var sorted_table=manager.get_nearest_building(houses_table,workplace_coords/16)
	for i in range(sorted_table.size()):
		if sorted_table[i]["inhabitants"]==[]:
			print("[*] "+str(id)+" found a new home : "+str(houses_table[i]["id"]))
			houses_table[manager.get_element_index(sorted_table[i]["id"],houses_table)]["inhabitants"].append(id)
			domicile=sorted_table[i]["id"]
			domicile_coords=sorted_table[i]["coords"]*16
			print(domicile_coords)
			return 0

func define_workplace(workplace_table):
	print("[*]defining new workplace for "+str(id))
	var found_job=false
	for i in range(workplace_table.size()):
		var jobs_available=get_jobs_available(workplace_table[i])
		print(jobs_available)
		if jobs_available!=[]:
			print("jobs avaliable : "+str(jobs_available))
			for ajob in jobs_available:
				if formation.has(ajob) and not found_job:
					found_job=true
					workplace_table[i]["employees"].append({"id":id,"job":ajob})
					workplace=workplace_table[i]["id"]
					workplace_coords=workplace_table[i]["coords"]*16
					if ajob=="worker":
						goto_work["coords"]=workplace_coords#workplace and domicile coords are for the building grids, every tile is 16x16
						work_task={"type":"work_factory","stop_time":17,"subtasks_loop":[goto_work,wait_1h]}
					elif ajob=="farmer":
						workplace_coords-=Vector2(8,8)
						goto_work["coords"]=workplace_coords
						goto_work["destination_type"]="outside"
						goto_work["min_distance"]=35
						work_task={"type":"work_factory","stop_time":17,"subtasks_loop":[
						goto_work,
						{"type":"wait","max_duration":3},
						{"type":"produce","commodity":carrot},
						{"type":"deposit","target_id":workplace,"commodity":carrot,"quantity":1,"target_table":"workplaces"}]
						}
						animated_sprite_2d.play("fuck")
					if ajob=="retailer":
						goto_work["coords"]=workplace_coords
						goto_work["destination_type"]="building"
						work_task={"type":"work_factory","stop_time":17,"subtasks_loop":[goto_work,wait_1h]}
					elif ajob=="shop_deliverer" and workplace_table[i]["farm"]["type"]!="nofarm":
						print("[!]shop deliverer")
						goto_work["coords"]=workplace_coords
						goto_work["destination_type"]="outside"
						work_task={"type":"work_factory","stop_time":17,"subtasks_loop":[
							{"type":"goto","min_distance":40,"coords":manager.get_info("workplaces",workplace,"farm")["coords"]*16,"max_duration":10,"destination_type":"outside"},
							{"type":"retrieve","target_id":manager.get_info("workplaces",workplace,"farm")["id"],"commodity":carrot,"quantity":3,"target_table":"workplaces"},
							goto_work,
							{"type":"deposit","target_id":workplace,"commodity":carrot,"quantity":3,"target_table":"workplaces"}]
							}
					print("[*] "+str(id)+" found a new work at "+workplace_table[i]["type"]+" number"+str(workplace)+" as a "+ajob)
					break
			
	
	return 0
			
func update_workplace(workplace_table):
	if workplace_coords==Vector2(0,0) or manager.get_element_index(workplace,manager.workplaces)==-1:#if no workplace or worplace deleted
		print("[!] need to find a new workplace")
		define_workplace(workplace_table)
func update_domicile(houses_table):
	if domicile_coords==Vector2(0,0) or manager.get_element_index(domicile,manager.houses)==-1:
		print("[*]need to find a new home")
		define_domicile(houses_table)
func set_id(new_id):
	id=new_id
func _ready():
	#define_workplace(manager.workplaces)
	#define_domicile(manager.houses)
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
			jobs_dict[i]=1
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
func get_jobs_available(workplace_dict):
	var jobs_dict=get_jobs_dict(workplace_dict["employees"])
	return get_substract_list(workplace_dict["employee_needs"],jobs_dict)
	
