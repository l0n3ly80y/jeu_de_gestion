extends TileMap

@onready var manager = $".."


#used to get the atlas coords based on road type
const connections_to_tile ={"edge":0,"corner":1,"I":2,"T":3,"X":4,"none":5}#x
const facing_to_tile ={"east":0,"west":1,"north":2,"south":3}#y

#used to get the atlas coords based on grass type
const grass_tileset_coords={0:Vector2(0,0),1:Vector2(0,1),2:Vector2(1,0),3:Vector2(1,1)}

#sets the size of the grid
const grid_size=64

#grid
var grid=[]#grid containing all the buildings

#mouse position on the tilemap
var mouse_tile_map_pos=Vector2(0,0)

#is building path inverted
var invert_build_path=false




#
func delete_building(coords,layout):
	var element=layout[coords.x][coords.y]
	if element["type"]=="house" or element["type"]=="house":
		manager.remove_building(element["type"],element["id"])
	layout[coords.x][coords.y]={
				"type":"grass",
				"facing":"east",
				"variant":randi_range(0,3),
				"id":0,
				"connections":"none"
	}
	
		
	


#path to build road
var road_begin=Vector2(0,0)
var road_end=Vector2(0,0)
func update_grid(layout):
	for house in manager.houses:
		var situation=get_connections(layout,house["coords"])
		layout[house["coords"].x][house["coords"].y]={
			"type":"house",
			"id":house["id"],
			"facing":situation[1],
			"connections":situation[0]
		}
	for workplace in manager.workplaces:
		layout[workplace["coords"].x][workplace["coords"].y]={
			"type":workplace["type"],
			"id":workplace['id'],
		}
	
func set_layout_on_tilemap(layout):
	for x in grid.size():
		for y in grid.size():
			var type=layout[x][y]["type"]
			if type=="grass":
				set_cell(0,Vector2(x,y),2,grass_tileset_coords[layout[x][y]["variant"]],0)
			elif type=="road":
				set_cell(0,Vector2(x,y),1,Vector2(connections_to_tile[layout[x][y]["connections"]],facing_to_tile[layout[x][y]["facing"]]))
			elif type=="road_preview":
				set_cell(0,Vector2(x,y),3,Vector2(0,0))
			elif type=="house":
				set_cell(0,Vector2(x,y),0,Vector2(connections_to_tile[layout[x][y]["connections"]],facing_to_tile[layout[x][y]["facing"]]))
			elif type=="factory":
				set_cell(0,Vector2(x,y),4,Vector2(0,0))
func clean_layout(layout):
	for x in grid.size():
		for y in grid.size():
			var type=layout[x][y]["type"]
			if type=="road_preview":
				grid[x][y]={
				"type":"grass",
				"facing":"east",
				"variant":randi_range(0,3),
				"id":0,
				"connections":"none"
			}
						
func get_connections(layout,coords:Vector2,type:="road"):#returns the road situations and the facing
	var x=coords.x
	var y=coords.y
	var up=layout[x][y-1]["type"]==type
	var down=layout[x][y+1]["type"]==type
	var left=layout[x-1][y]["type"]==type
	var right=layout[x+1][y]["type"]==type
	var connections="none"
	var facing="east"
	
	
	if right:#droite
		if left:#droite+gauche
			if up:#droite+gauche+haut
				if down:#partout
					connections="X"
					facing="east"
				else:#droite+gauche+haut+!bas
					connections="T"
					facing="north"
			else:#droite+gauche+!haut
				if down:#droite+gauche+!haut+bas
					connections="T"
					facing="south"
				else:#droite+gauche+!haut+!bas
					connections="I"
					facing="east"
		else:#droite+!gauche
			if up:#droite+!gauche+haut
				if down:#droite+!gauche+haut+bas
					connections="T"
					facing="east"
				else:#droite+!gauche+haut+!bas
					connections="corner"
					facing="north"
			else:#droite+!gauche+!haut
				if down:#droite+!gauche+!haut+bas
					connections="corner"
					facing="east"
				else:#droite+!gauche+!haut+!bas
					connections="edge"
					facing="east"
	else:#!droite
		if left:#!droite+gauche
			if up:#!droite+gauche+haut
				if down:#!droite+gauche+haut+bas
					connections="T"
					facing="west"
				else:#!droite+gauche+haut+!bas
					connections="corner"
					facing="west"
			else:#!droite+gauche+!haut
				if down:#!droite+gauche+!haut+bas
					connections="corner"
					facing="south"
				else:#!droite+gauche+!haut+!bas
					connections="edge"
					facing="west"
		else:#!droite+!gauche
			if up:#!droite+!gauche+haut
				if down:#!droite+!gauche+haut+bas
					connections="I"
					facing="north"
				else:#!droite+!gauche+haut+!bas
					connections="edge"
					facing="north"
			else:#!droite+!gauche+!haut
				if down:#!droite+!gauche+!haut+bas
					connections="edge"
					facing="south"
				else:#isole
					connections="none"
					facing="east"
	return [connections,facing]
		
func place_road(coords:Vector2,layout,depth:=1):
	var situation=get_connections(layout,coords)
	var connections=situation[0]
	var facing=situation[1]
	if layout[coords.x][coords.y]["type"]=="grass" or layout[coords.x][coords.y]["type"]=="road":#checking if spot is eligible for road
		layout[coords.x][coords.y]={
			"type":"road",
			"facing":facing,
			"variant":0,
			"id":0,
			"connections":connections
			}
		
		if depth==1:#updating adjascent roads
			if layout[coords.x+1][coords.y]["type"]=="road":#right
				place_road(Vector2(coords.x+1,coords.y),layout,0)
			if layout[coords.x-1][coords.y]["type"]=="road":#left
				place_road(Vector2(coords.x-1,coords.y),layout,0)
			if layout[coords.x][coords.y-1]["type"]=="road":#up
				place_road(Vector2(coords.x,coords.y-1),layout,0)
			if layout[coords.x][coords.y+1]["type"]=="road":#down
				place_road(Vector2(coords.x,coords.y+1),layout,0)
		return 1
			
	else:
		
		return 0
	


# Called when the node enters the scene tree for the first time.
func _ready():
	#first sets the empty cases for the grid
	for x in grid_size:
		grid.append([])
		for y in grid_size:
			grid[x].append({
				"type":"grass",
				"facing":"east",
				"variant":randi_range(0,3),
				"id":0,
				"connections":"none"
			})
	
	place_road(Vector2(3,3),grid)
	#print(grid[3][3])	
	#place_road(Vector2(4,3),grid)
	set_layout_on_tilemap(grid)


func get_L_path(a:Vector2,b:Vector2,invert:=false):
	var path=[]
	var xa=a.x
	var xb=b.x
	var ya=a.y
	var yb=b.y
	var x_begin=min(xa,xb)
	
	var x_end=max(xa,xb)
	if xa<xb:
		x_end+=1
	elif xa>xb and invert:
		x_end+=1
	var y_begin=min(ya,yb)
	var y_end=max(ya,yb)
	if invert:
		for y in range(y_begin,y_end):
			path.append(Vector2(xa,y))
		for x in range(x_begin,x_end):
			path.append(Vector2(x,yb))
	else:
		for x in range(x_begin,x_end):
			path.append(Vector2(x,ya))
		for y in range(y_begin,y_end):
			path.append(Vector2(xb,y))
	return path
func connect_road(a:Vector2,b:Vector2,layout,invert:=false,preview:=false):
	var path=get_L_path(a,b,invert)
	for coords in path:
		if preview and layout[coords.x][coords.y]["type"]=="grass":#check if it's a preview and if we're not erasi
			layout[coords.x][coords.y]={
				"type":"road_preview",
				"facing":"east",
				"variant":0,
				"id":0,
				"connections":"none"
			}
		else:
			place_road(coords,layout)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mouse_tile_map_pos=local_to_map(get_global_mouse_position())
	if manager.cursor_state=="building_road":
		connect_road(road_begin,mouse_tile_map_pos,grid,invert_build_path,true)
	set_layout_on_tilemap(grid)
	clean_layout(grid)
	update_grid(grid)
