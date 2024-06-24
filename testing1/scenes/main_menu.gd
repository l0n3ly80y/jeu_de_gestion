extends Node2D
var test="abracadaba"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_new_game_button_pressed():
	Global.starting_point="new_game"
	get_tree().change_scene_to_file("res://main.tscn")
	


func _on_continue_pressed():
	Global.starting_point="continue"
	get_tree().change_scene_to_file("res://main.tscn")


func _on_load_game_button_pressed():
	load_game_screen()
func load_game_screen():
	pass
