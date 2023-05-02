extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	MusicPlayer.play_music("main");


func _on_start_button_pressed():
	SceneManager.change_scene("res://screens/IntroScene.tscn");


func _on_credits_button_pressed():
	SceneManager.change_scene("res://screens/CreditsScene.tscn");
