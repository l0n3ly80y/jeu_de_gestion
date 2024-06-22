extends TileMap
#roads
const facing_to_tile ={"east":0,"west":1,"north":2,"south":3}
const connections_to_tile ={"edge":0,"corner":1,"I":2,"T":3,"X":4,"None":5}
var Grid_size=128
var atlas_coordonates=Vector2(0,0)
var Layout=[[]]

var mouse_tile_map_pos=Vector2(0,0)

var update_timer=0

#for road building
var click_delay=false
var building_a_road=false
var beginning_of_road=Vector2(0,0)
var ending_of_road=Vector2(0,0)

static func string_to_vector2(string := "") -> Vector2:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")

		return Vector2(int(array[0]), int(array[1]))

	return Vector2.ZERO
# Called when the node enters the scene tree for the first time.

	
	
	
func place_road(coords,layout,depth):
	var x=coords.x
	var y=coords.y
	var type="empty"
	var connections=""
	var facing=""
	#determine the nature of the road
	if layout[x+1][y]["type"]=="road":#a droite
		if layout[x-1][y]["type"]=="road":#a droite+gauche
			if layout[x][y-1]["type"]=="road":#a droite+gauche+haut
				if layout[x][y+1]["type"]=="road":#partout
					connections="X"
					facing="east"
				else:#droite+gauche+haut+!bas
					connections="T"
					facing="north"
			else:#droite+gauche+!haut
				if layout[x][y+1]["type"]=="road":#droite+gauche+!haut+bas
					connections="T"
					facing="south"
				else:#droite+gauche+!haut+!bas
					connections="I"
					facing="east"
		else:#droite+!gauche
			if layout[x][y-1]["type"]=="road":#droite+!gauche+haut
				if layout[x][y+1]["type"]=="road":#droite+!gauche+haut+bas
					connections="T"
					facing="east"
				else:#droite+!gauche+haut+!bas
					connections="corner"
					facing="north"
			else:#droite+!gauche+!haut
				if layout[x][y+1]["type"]=="road":#droite+!gauche+!haut+bas
					connections="corner"
					facing="east"
				else:#droite+!gauche+!haut+!bas
					connections="edge"
					facing="east"		
	else:#!droite
		if layout[x-1][y]["type"]=="road":#!droite+gauche
			if layout[x][y-1]["type"]=="road":#!droite+gauche+haut
				if layout[x][y+1]["type"]=="road":#!droite+gauche+haut+bas
					connections="T"
					facing="west"
				else:#!droite+gauche+haut+!bas
					connections="corner"
					facing="west"
			else:#!droite+gauche+!haut
				if layout[x][y+1]["type"]=="road":#!droite+gauche+!haut+bas
					connections="corner"
					facing="south"
				else:#!droite+gauche+!haut+!bas
					connections="edge"
					facing="west"
				
		else:#!droite+!gauche
			if layout[x][y-1]["type"]=="road":#!droite+!gauche+haut
				if layout[x][y+1]["type"]=="road":#!droite+!gauche+haut+bas
					connections="I"
					facing="north"
				else:#!droite+!gauche+haut+!bas
					connections="edge"
					facing="north"
			else:#!droite+!gauche+!haut
				if layout[x][y+1]["type"]=="road":#!droite+!gauche+!haut+bas
					connections="edge"
					facing="south"
				else:#!droite+!gauche+!haut+!bas
					connections="None"
					facing="east"
	#print(connections)
	#print(facing)
	Layout[x][y]={#placing the road
		"facing":facing,
		"connections":connections,#edge,corner,T,X,I
		"type":"road"#road,house,empty
	}
	#adapting the adjascent roads
	if depth==1:
		if layout[x+1][y]["type"]=="road":
			place_road(Vector2(x+1,y),layout,0)
		if layout[x-1][y]["type"]=="road":
			place_road(Vector2(x-1,y),layout,0)
		if layout[x][y+1]["type"]=="road":
			place_road(Vector2(x,y+1),layout,0)
		if layout[x][y-1]["type"]=="road":
			place_road(Vector2(x,y-1),layout,0)
		
		
		
	
			
			
					
	
	
	
func connect_b_to_a(a:Vector2,b:Vector2,layout,reverted:bool,preview:=false):
	var xa=a.x
	var ya=a.y
	var xb=b.x
	var yb=b.y
	var final_x=0
	var final_y=0
	if reverted:
		if xa>xb:#si a est plus a droite que b
			for x in range(xb,xa):#on commence par aller en x de b a a
				if preview:
					layout[x][yb]={"facing":"east","connections":"none","type":"preview_road"}
				else:
					place_road(Vector2(x,yb),layout,1)
				final_x=x
			
		else:
			for x in range(xa,xb):#on commence par aller en x de b a a
				if preview:
					layout[x][ya]={"facing":"east","connections":"none","type":"preview_road"}
					pass
				else:
					place_road(Vector2(x,ya),layout,1)
				final_x=x
		if ya>yb:#si a est en dessous de b
			for y in range(yb,ya):
				if preview:
					layout[final_x][y]={"facing":"east","connections":"none","type":"preview_road"}
					pass
				else:
					place_road(Vector2(final_x,y),layout,1)
		else:
			for y in range(ya,yb):
				if preview:
					layout[final_x][y]={"facing":"east","connections":"none","type":"preview_road"}
				else:
					place_road(Vector2(final_x,y),layout,1)
	else:
		if ya>yb:#si a est en dessous de b
			for y in range(yb,ya):
				if preview:
					layout[xb][y]={"facing":"east","connections":"none","type":"preview_road"}
				else:
					place_road(Vector2(xb,y),layout,1)
				final_y=y
		else:
			for y in range(ya,yb):
				if preview:
					layout[xa][y]={"facing":"east","connections":"none","type":"preview_road"}
				else:
					place_road(Vector2(xa,y),layout,1)
				final_y=y
			if ya==yb:
				final_y=ya
		if xa>xb:#si a est plus a droite que b
			
			for x in range(xb,xa):#on commence par aller en x de b a a
				if preview:
					layout[x][final_y]={"facing":"east","connections":"none","type":"preview_road"}
				else:
					place_road(Vector2(x,final_y),layout,1)
			
		else:
			
			for x in range(xa,xb):#on commence par aller en x de b a a
				if preview:
					layout[x][final_y]={"facing":"east","connections":"none","type":"preview_road"}
				else:
					place_road(Vector2(x,final_y),layout,1)
	
	
func duplicate_layout(layout):
	var dupli=[]
	for i in layout:
		dupli.append(i.duplicate())
	return dupli	
				
func set_tiles_from_layout(layout):#sets the tiles from the said layout, a matrix
	for x in layout.size()-1:
		for y in layout[0].size():
			if layout[x][y]["type"]=="road":
				
				atlas_coordonates=Vector2(connections_to_tile[layout[x][y]["connections"]],facing_to_tile[layout[x][y]["facing"]])
				set_cell(0,Vector2(x,y),2,atlas_coordonates,0)
			if layout[x][y]["type"]=="preview_road":
				atlas_coordonates=Vector2(5,0)
				set_cell(0,Vector2(x,y),2,atlas_coordonates,0)
				
func clean_layout(layout):
	for x in layout.size()-1:
		for y in layout[0].size():
			print(layout[x][y])
			if layout[x][y]["type"]=="preview_road":
				layout[x][y]="empty"
				
		
func _ready():
	for x in Grid_size:
		Layout.append([])
	for x in Grid_size:
		for y in Grid_size:
			Layout[x].append({
				"facing":"east",
				"connections":"edge",#edge,corner,T,X,I
				"type":"empty"#road,house,empty
			})
	#place_road(Vector2(5,5),Layout,1)
	#connect_b_to_a(Vector2(8,0),Vector2(14,9),Layout,false)
	#set_tiles_from_layout(Layout)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_timer+=delta*10
	if update_timer>1000:
		print("kk")
		set_tiles_from_layout(Layout)
		clean_layout(Layout)
	mouse_tile_map_pos=local_to_map(get_global_mouse_position())
	if building_a_road:
		connect_b_to_a(beginning_of_road,mouse_tile_map_pos,Layout,false,true)
		

func _input(event):
	if event is InputEventMouseButton:
		if click_delay:
			click_delay=false
			if not building_a_road:
				print("begin :")
				beginning_of_road=mouse_tile_map_pos
				building_a_road=true
				print(beginning_of_road)
			else:
				print("end :")
				ending_of_road=mouse_tile_map_pos
				print(ending_of_road)
				building_a_road=false
				connect_b_to_a(beginning_of_road,ending_of_road,Layout,false)
		else:
			click_delay=true
