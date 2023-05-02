extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_back_button_pressed():
	SceneManager.change_scene("res://screens/StartScene.tscn");
