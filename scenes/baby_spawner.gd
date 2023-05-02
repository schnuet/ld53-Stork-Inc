extends Node2D

var width = 1140;
var height = 600;

signal marker_spawned(marker);

var MarkerScene = preload("res://scenes/marker.tscn");

func spawn_baby_marker():
	var animal_type_index = randi() % Game.available_animal_types.size();
	var animal_type = Game.available_animal_types[animal_type_index];
	
	# CREATE the start marker
	
	var marker: Marker = MarkerScene.instantiate();
	marker.animal_type = animal_type;
	marker.marker_type = Game.MARKER_TYPE.START;
	
	var x = randi_range(0, width);
	var y = randi_range(0, height);
	marker.position = Vector2(x, y);
	
	add_child(marker);
	emit_signal("marker_spawned", marker);
		
	# DO NOT SPAWN END MARKER ANYMORE
	#	await get_tree().create_timer(1.0).timeout
	#
	#	# create the end marker too
	#	var end_marker: Marker = MarkerScene.instantiate();
	#	end_marker.animal_type = animal_type;
	#	end_marker.marker_type = Game.MARKER_TYPE.END;
	#
	#	var end_x = randi_range(0, width);
	#	var end_y = randi_range(0, height);
	#	end_marker.position = Vector2(end_x, end_y);
	#
	#	add_child(end_marker);
	#	emit_signal("marker_spawned", end_marker);
	

	
	
	

func start_timer(time):
	$Timer.start(time);
	

func _on_timer_timeout():
	# Make next timer harder
	
	var spawn_variance_time = 2;
		
	spawn_baby_marker();
	
	var day_minimum = 3;
	
	if Game.days == 0:
		spawn_variance_time = 4;
		day_minimum = 7.5;
	if Game.days == 1:
		spawn_variance_time = 3;
		day_minimum = 2;
	if Game.days == 2:
		spawn_variance_time = 2;
		day_minimum = 1.75;
	if Game.days == 3:
		spawn_variance_time = 2;
		day_minimum = 1.25;
	if Game.days == 4:
		spawn_variance_time = 2;
		day_minimum = 0.9;
	if Game.days >= 5:
		spawn_variance_time = 1.7;
		day_minimum = 0.8;
	if Game.days == 6:
		spawn_variance_time = 1.4;

	var delay = day_minimum + randi_range(0, spawn_variance_time);
	
	print(delay, " ", day_minimum);
	
	$Timer.start(delay);
