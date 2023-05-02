extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/Babies.hide();
	$Control/Workers.hide();
	$Control/Income.hide();
	$Control/Expenses.hide();
	$Control/ContinueButton.hide();
	
	$Control/Babies/result.text = str(Game.babies_delivered_in_total);
	$Control/Expenses/result.text = str(Game.total_expenses);
	$Control/Income/result.text = str(Game.total_income);
	$Control/Workers/result.text = str(Game.employed_birds.size()) + "/8";
	
	await get_tree().create_timer(1.0).timeout
	$Control/Babies.show();
	await get_tree().create_timer(1.0).timeout
	$Control/Workers.show();
	await get_tree().create_timer(1.0).timeout
	$Control/Income.show();
	await get_tree().create_timer(1.0).timeout
	$Control/Expenses.show();
	await get_tree().create_timer(1.0).timeout
	
	$Control/ContinueButton.show();
	


func _on_continue_button_pressed():
	SceneManager.change_scene("res://screens/EndScene.tscn");
