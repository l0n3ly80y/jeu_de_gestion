extends CanvasLayer

@onready var manager = $"."
@onready var building_grid = $building_grid




# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused=true
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_continue_button_pressed():
	get_tree().paused=false
	queue_free()


func _on_save_quit_button_pressed():
	pass # Replace with function body.


func _on_save_game_button_pressed():
	manager.save(manager.houses,manager.workplace,manager.agents,building_grid.grid,"res://saves/manual_save_of"+Time.get_datetime_string_from_system()+".save")
	
	

