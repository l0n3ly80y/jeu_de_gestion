extends StaticBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var entrance = $entrance
var id=0
var coords=Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func get_data():
	return {"id":id,"position":position,"coords":coords}
func set_data(data):
	id=data["id"]
	position=data["position"]
	coords=data["coords"]
	
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
