class_name Bird
extends Area2D

signal click;
signal baby_delivered;

var bird_name = Game.WorkerName.stan;

var babies_carried = [];
var max_baby_capacity = 1;

var target: Area2D = null;
var target_position = null;

var velocity = Vector2.ZERO;
var max_speed = 200;
var max_idle_speed = 80;
var speed = 0;

var mouse_inside = false;
var selected = false;

var random_position = null;


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("default");
	update_hat();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var target_velocity = Vector2.ZERO;
	
	var _position = null;
	
	if target != null:
		_position = target.global_position;
	
	if target_position != null:
		_position = target_position;
	
	if babies_carried.size() > 0:
		var baby_target = get_baby_marker(babies_carried[0]);
		_position = baby_target.global_position;
	
	if _position != null:
		# move to target
		$NavigationAgent2D.target_position = _position;
		if $NavigationAgent2D.is_navigation_finished():
			# HANDLE marker interaction:
			handle_marker_collision();
			
			if target_position != null and _position.is_equal_approx(target_position):
				target_position = null;
				
			_position = null;
			
			return;
		
		if speed < max_speed:
			speed += (max_speed - speed) * 0.25 * delta;
		
		var next_position = $NavigationAgent2D.get_next_path_position();
		var distance = $NavigationAgent2D.distance_to_target();
		target_velocity = min(max_speed, distance * 2) * ((next_position - global_position).normalized());
	
	elif random_position != null:
		# move to target
		$NavigationAgent2D.target_position = random_position;
		if $NavigationAgent2D.is_navigation_finished():
			random_position = null;
			return;
		
		if speed < max_speed:
			speed += (max_speed - speed) * 0.25 * delta;
		
		var next_position = $NavigationAgent2D.get_next_path_position();
		var distance = $NavigationAgent2D.distance_to_target();
		target_velocity = max_idle_speed * ((next_position - global_position).normalized());
	
	else:
		random_position = Vector2(randi() % 1280, randi() % 720);
		
	
	velocity += (target_velocity - velocity) * 2 * delta;
	global_position += velocity * delta;
	
	update_sprite_direction();
	
func update_sprite_direction():
	if velocity.x > 1:
		$AnimatedSprite2D.scale.x = -abs($AnimatedSprite2D.scale.x);
	else:
		$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x);
		

func set_target(t):
	target = t;
	update_baby_label();

func set_target_position(pos: Vector2):
	target = null;
	target_position = pos;

func handle_marker_click(marker: Marker):
	self.target = marker;
	target_position = marker.global_position;
	
	random_position = null;
	
	print("bird received marker ", marker);

func handle_marker_collision():
	var t = target;
	
	if get_next_baby_marker():
		t = get_next_baby_marker();
	
	if t == null:
		return;
		
	if t.is_bird_arrived(self):
		if t.marker_type == Game.MARKER_TYPE.START:
			get_baby(t);
			target = null;
			
		elif t.marker_type == Game.MARKER_TYPE.END:
			deliver_baby(t);
			if t == target:
				target = null;

func get_baby(marker: Marker):
	print("start target reached");
	if babies_carried.size() >= max_baby_capacity:
		print("MAX babies reached")
		return;
	
	babies_carried.append(marker.baby);
	update_baby_label();

	target = get_baby_marker(marker.baby);
	target_position = target.global_position;
	
	$AnimatedSprite2D/Korb.show();
	
	$PickupSound.play(0);
	
	# REMOVE the baby marker
	marker.queue_free();

func get_baby_marker(baby):
	var baby_kind = Game.ANIMAL_TYPE.keys()[baby.animal_type];

	return get_tree().get_nodes_in_group("end_" + baby_kind)[0];

func deliver_baby(marker: Marker):
	
	for baby in babies_carried:
		if baby.animal_type == marker.animal_type:
			emit_signal("baby_delivered", baby);
			$DropoffSound.play(0);
			babies_carried.erase(baby);
			update_baby_label();
			
			$AnimatedSprite2D/Korb.hide();
			
			# don't remove end marker
			# marker.queue_free();
			
			return true;
	return false;


func update_baby_label():
	$Label.text = "";
	for baby in babies_carried:
		$Label.text += baby.name + " (" + Game.ANIMAL_TYPE.keys()[baby.animal_type] + ") ";
	
	
func select():
	selected = true;
	$Circle.show();

func deselect():
	selected = false;
	$Circle.hide();

# HANDLE MOUSE CLICKS

func _input(event):
	if not mouse_inside:
		return;
		
	if event is InputEventMouseButton:
		if event.is_pressed():
			get_viewport().set_input_as_handled();
			print("bird clicked");
			emit_signal("click", self);

func _on_mouse_entered():
	mouse_inside = true;

func _on_mouse_exited():
	mouse_inside = false;
	

func get_farthest_corner():
	var x = 80;
	var y = 80;
	if global_position.x < 640:
		x = 1200;
	if global_position.y < 320:
		y = 640;
	
	return Vector2(x, y);

func get_next_baby():
	if babies_carried.size() <= 0:
		return null;
	return babies_carried[0];

func get_next_baby_marker():
	var baby = get_next_baby();
	if baby == null:
		return null;
	
	return get_baby_marker(baby);

func reset():
	target = null;
	babies_carried = [];
	target_position = null;
	random_position = null;
	$AnimatedSprite2D/Korb.hide();
	
	update_baby_label();

func get_profile():
	return Game.bird_profiles[bird_name];

func update_hat():
	var hats = $AnimatedSprite2D/Hat.get_children();
	for hat in hats:
		if hat.name == get_profile().get("key"):
			hat.show();
		else:
			hat.hide();
