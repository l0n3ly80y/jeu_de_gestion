extends Node2D
@onready var building_grid = $building_grid
@onready var cursor_state_indicator = $player/Camera2D/UI/HBoxContainer/cursor_state_indicator
@onready var date_label = $player/Camera2D/UI/HBoxContainer/date_label


#houses database
var houses=[]
#workplaces
var workplaces=[]
const workplace_types=["factory"]
#agents database
var agents=[]
#time management
const weekdays=["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]
const months=["january","february","march","april","may","june","july","august","september","october","november","december"]
const months_length=[31,29,31,30,31,30,31,31,30,31,30,31]
var date={"hour":0,"day":1,"month":0,"year":0,"weekday":0}




#mouse screen position
var mouse_screen_pos=Vector2(0,0)
#to check if the mouse is inside the UI zone
var is_mouse_on_UI=false
#example: building a road
var cursor_state="none"



var basic_house={"id":0,
"coords":Vector2(0,0),
"inhabitants":[],
"rent":0}
func generate_id(table):#returns a suitable id for a new element in a table
	var maximum_id=0
	for element in table:

		if element["id"]>=maximum_id:
			maximum_id=element["id"]+1
	print(maximum_id)
	return maximum_id

func create_house(coords:Vector2,table,layout):
	if building_grid.grid[coords.x][coords.y]["type"]=="grass":
		table.append({
			"id":generate_id(table),
			"coords":coords,
			"inhabitants":[],
			"rent":0
		})
		return 1
	else:
		return 0



func create_workplace(coords:Vector2,table,type="factory"):
	if building_grid.grid[coords.x][coords.y]["type"]=="grass":
		table.append({
			"type":type,
			"id":generate_id(table),
			"coords":coords,
			"employees":[]
		})
		return 1
	else:
		return 0
func create_agent(coords:Vector2,table):
	if building_grid.grid[coords.x][coords.y]["type"]=="road":
		var id=generate_id(table)
		var agent=preload("res://scenes/agent.tscn").instantiate()
		table.append({"id":id,
		"object":agent})
		add_child(agent)
		agent.position=coords*16
		agent.id=id
func get_id_index(table,id:int):
	for i in table.size():
		if table[i]["id"]==id:
			return i
func get_date_string(date_dict:Dictionary)->String:
	var day_suffix="th"
	if date_dict["day"]==1:
		day_suffix="st"
	elif date_dict["day"]==2:
		day_suffix="nd"
	elif date_dict["day"]==3:
		day_suffix="rd"
	return str(date_dict["hour"])+"h "+weekdays[date_dict["weekday"]]+" the "+str(date_dict["day"])+day_suffix+" of "+months[date_dict["month"]]+" "+str(date_dict["year"])
	
# Called when the node enters the scene tree for the first time.
func _ready():
	#create_house(Vector2(5,9),houses,building_grid.grid)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cursor_state_indicator.text=cursor_state#updates the label of the UI
	mouse_screen_pos=get_viewport().get_mouse_position()
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and not is_mouse_on_UI:
			if cursor_state=="building_road_begin":
				building_grid.road_begin=building_grid.mouse_tile_map_pos
				cursor_state="building_road"
			elif cursor_state=="building_road":
				building_grid.road_end=building_grid.mouse_tile_map_pos
				cursor_state="building_road_begin"
				building_grid.connect_road(building_grid.road_begin,building_grid.road_end,building_grid.grid,building_grid.invert_build_path)
			elif cursor_state=="building_house":
				create_house(building_grid.mouse_tile_map_pos,houses,building_grid.grid)
			elif cursor_state=="spawn_agent":
				create_agent(building_grid.mouse_tile_map_pos,agents)
			elif cursor_state=="building_factory":
				create_workplace(building_grid.mouse_tile_map_pos,workplaces)
			elif cursor_state=="delete_building":
				building_grid.delete_building(building_grid.mouse_tile_map_pos,building_grid.grid)
				cursor_state="none"
				
	elif event is InputEventKey:
		if event.pressed and event.keycode==KEY_I:
			print("inverting")
			building_grid.invert_build_path= building_grid.invert_build_path!=true
			print(building_grid.invert_build_path)




func remove_building(type:String,id:int):
	if type=="house":
		var index_of_building=get_element_index(id,houses)
		houses.remove_at(index_of_building)
	elif type in workplace_types:
		var index_of_building=get_element_index(id,workplaces)
		
		workplaces.remove_at(index_of_building)
	update_agents()
func _on_road_button_pressed():
	if cursor_state=="none":		
		cursor_state="building_road_begin"
	else:
		cursor_state="none"


func _on_house_button_pressed():
	if cursor_state=="none":
		cursor_state="building_house"
	else:
		cursor_state="none"


func _on_neutral_button_pressed():
	cursor_state="none"

func _on_ui_zone_mouse_entered():
	is_mouse_on_UI=true

func _on_ui_zone_mouse_exited():
	is_mouse_on_UI=false

func _on_spawn_agent_button_pressed():
	cursor_state="spawn_agent"

func _on_build_factory_pressed():
	cursor_state="building_factory"
	
func _on_delete_button_pressed():
	cursor_state="delete_building"
	

func _on_timer_timeout():
	date["hour"]+=1
	if date["hour"]>=24:
		update_agents()
		date["hour"]=0
		date["day"]+=1
		if date["weekday"]<6:
			date["weekday"]+=1
		else:
			date["weekday"]=0
		if date["day"]>=months_length[date["month"]]:
			date["day"]=1
			date["month"]+=1
			if date["month"]>=12:
				date["month"]=0
				date["year"]+=1
	date_label.text=get_date_string(date)

func update_agents():
	for agent in agents:
		agent["object"].update_workplace(workplaces)
		agent["object"].update_domicile(houses)
		
func get_element_index(id:int,table):
	for element_index in table.size():
		if table[element_index]["id"]==id:
			return element_index
	return -1
func get_nearest_houses(table,coords:Vector2):#returns the houses list but sorted from shortest to longest distance from coords
	var distance_min=INF
	var distance_to_house=0
	var unsorted_houses=table.duplicate()
	var nearest_houses=[]
	var minimum_index=0
	for i in unsorted_houses.size():
		distance_min=INF
		minimum_index=0
		for j in unsorted_houses.size():
			distance_to_house=distance(unsorted_houses[i]["coords"],coords)
			if distance_to_house<distance_min:
				distance_min=distance_to_house
				minimum_index=j
		nearest_houses.append(unsorted_houses[minimum_index])
		unsorted_houses.remove_at(minimum_index)
#a tester<	

func distance(a:Vector2,b:Vector2):
	return sqrt((a.x-b.x)**2+(a.y-b.y)**2)
