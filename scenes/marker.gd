@tool
class_name Marker
extends Area2D

signal click;

@export var animal_type = Game.ANIMAL_TYPE.fox : set = _set_animal_type, get = _get_animal_type;
@export var marker_type = Game.MARKER_TYPE.START  : set = _set_marker_type, get = _get_marker_type; # start | end

var mouse_inside = false;

@onready var baby: Baby = preload("res://scenes/baby.tscn").instantiate();

func _ready():
	# make sure the babys animal type is the same as the marker.
	baby.animal_type = animal_type;
	
	update_marker_image();
	
	# INTRO ANIMATION
	self.modulate = Color.TRANSPARENT;
	self.scale = Vector2.ZERO;
	var tween = get_tree().create_tween();
	tween.tween_property(self, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_SINE);
	tween.tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BOUNCE);


func is_bird_arrived(bird: Bird):
	for _bird in get_overlapping_areas():
		return bird == _bird;
			
	return false;


func _set_animal_type(new_animal_type):
	animal_type = new_animal_type;
	update_marker_image();
	
func _get_animal_type():
	return animal_type;
	

func _set_marker_type(new_type):
	marker_type = new_type;
	update_marker_image();
	
func _get_marker_type():
	return marker_type;

func update_marker_image():
	var animal_type_str = Game.ANIMAL_TYPE.keys()[animal_type];
	$MarkerImage/CustomIcon.animation = animal_type_str;
	
	if marker_type == Game.MARKER_TYPE.END:
		$MarkerImage.animation = "end";
	else:
		$MarkerImage.animation = "start";



# CLICK HANDLING

func _input(event):
	if not mouse_inside:
		return;
	if event is InputEventMouseButton:
		if event.is_pressed():
			get_viewport().set_input_as_handled();
			emit_signal("click", self);


func _on_mouse_entered():
	mouse_inside = true;

func _on_mouse_exited():
	mouse_inside = false;

