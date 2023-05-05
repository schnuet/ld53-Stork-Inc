extends Node2D

var selected_bird: Bird;
var BirdScene = preload("res://scenes/bird.tscn");

var markers = [];
var birds = [];

var selected_worker_panel = null;

var time_of_day = 360;

var first_baby_delivered = false;

@onready var world_map = $NavigationRegion2D/WorldMap;

func _ready():
	# create_bird();
	
	# on_day_end();
	hide_game_end_panel();
	
	# CONNECT MARKER EVENTS TO END MARKERS
	var existing_markers = get_tree().get_nodes_in_group("marker");
	for marker in existing_markers:
		_on_baby_spawner_marker_spawned(marker);
		
	var existing_birds = get_tree().get_nodes_in_group("bird");
	for bird in existing_birds:
		birds.append(bird);
		
	if selected_bird == null:
		select_bird($NavigationRegion2D/birds/Bird);
	
	await get_tree().create_timer(2.0).timeout
	
	$NavigationRegion2D/BabySpawner.spawn_baby_marker();
	
	MusicPlayer.play_music("main");
	
func _process(delta):
	var h = remap(time_of_day, 6 * 60, 18 * 60, 300, 340);
	
	var s = 0;
	if (time_of_day < 9.5 * 60):
		s = remap(time_of_day, 6 * 60, 9.5 * 60, 30, 0);
	elif (time_of_day > 16 * 60):
		s = remap(time_of_day, 16 * 60, 18 * 60, 0, 40);
	
	var v = 100;
	if (time_of_day < 9.5 * 60):
		v = remap(time_of_day, 6 * 60, 9.5 * 60, 85, 100);
	elif (time_of_day > 16 * 60):
		v = remap(time_of_day, 16 * 60, 18 * 60, 100, 85);
		
	var modulate_color = Color.from_hsv(h / 360, s / 100, v / 100);
	
	$NavigationRegion2D/birds.modulate = modulate_color;
	world_map.modulate = modulate_color;
	
	$TimeArea/Sonnenuhr/Zeiger.rotation = remap(time_of_day, 6 * 60, 18 * 60, 0, 6.28319);

func create_bird(bird_name):
	var bird: Bird = BirdScene.instantiate();
	bird.bird_name = bird_name;
	$NavigationRegion2D/birds.add_child(bird);
	
	
	bird.connect("click", _on_bird_click);
	bird.connect("baby_delivered", _on_bird_baby_delivered);
	birds.append(bird);
	

func _on_marker_click(marker: Marker):
	if selected_bird:
		selected_bird.handle_marker_click(marker);
		
		$ClickSound.play();
		
		# deselect_bird();

func _unhandled_input(event):
	if selected_bird == null:
		return;

	if event is InputEventMouseButton and event.is_pressed():
		print("unhandled click");
		selected_bird.set_target_position(get_global_mouse_position());

func _on_bird_click(bird: Bird):
	select_bird(bird);
	
	print("bird click ", bird);

func select_bird(bird):
	deselect_bird();
	selected_bird = bird;
	selected_bird.select();

func deselect_bird():
	if selected_bird != null:
		selected_bird.deselect();
		selected_bird = null;
	
	
func _on_bird_baby_delivered(_baby: Baby):
	add_to_coins(10);
	Game.coins_made_today += 10;
	Game.babies_delivered_today += 1;
	Game.babies_delivered_in_total += 1;

	
	if not first_baby_delivered:
		$NavigationRegion2D/BabySpawner.start_timer(1.0);


func _on_baby_spawner_marker_spawned(marker:Marker):
	marker.connect("click", _on_marker_click);
	marker.connect("tree_exited", remove_marker.bind(marker))
	markers.append(marker);

func remove_marker(marker):
	markers.erase(marker);


func _on_time_timer_timeout():
	time_of_day += 10;
	update_time_label();
	
	if time_of_day == 18 * 60:
		on_day_end();
	
func update_time_label():
	var hours = floori(time_of_day / 60);
	var minutes = time_of_day - hours * 60;
	
	var hours_text = str(hours);
	if hours < 10:
		hours_text = "0" + hours_text;
	
	var minutes_text = str(minutes);
	if minutes < 10:
		minutes_text = "0" + minutes_text;
		
	$TimeArea/TimeLabel.text = hours_text + ":" + minutes_text;


# DAY END

func on_day_end():
	var next_marker_shown = false;
	
	for marker in markers:
		if marker.marker_type == Game.MARKER_TYPE.START:
			# REMOVE ALL START MARKERS FROM MAP
			marker.queue_free();
		elif marker.visible == false and not next_marker_shown:
			# SHOW NEXT ANIMAL END MARKER
			marker.show();
			Game.available_animal_types.append(marker.animal_type);
			next_marker_shown = true;
	
	# REMOVE ALL BIRD BABIES:
	for bird in birds:
		bird.reset();
	
	deselect_bird();
	
	$DayEndPopup/DayFact/Fact.text = Game.stork_facts[Game.days];
	
	get_tree().paused = true;
	
	
	
	var baby_bonus = Game.get_baby_bonus();
	var employee_costs = Game.get_employee_costs();
	
	$DayEndPopup.show();
	$DayEndPopup/DayEnd.show();
	await get_tree().create_timer(1.0).timeout
	
	update_delivered_babies_label();
	
	await get_tree().create_timer(1.0).timeout
	
	add_to_coins(baby_bonus);
	$DayEndPopup/DayEnd/Babies/BabyBonus.show();
	$DayEndPopup/DayEnd/Babies/BabyBonus/Label.text = "+" + str(Game.get_baby_bonus());
	
	Game.total_gain_today = Game.coins_made_today + baby_bonus - employee_costs;
	
	
	await get_tree().create_timer(2.0).timeout
	
	update_coins_made_label();
	await get_tree().create_timer(1.0).timeout

	update_employee_costs_label();
	add_to_coins(-employee_costs);
	await get_tree().create_timer(1.0).timeout

	update_total_of_day_label();
	await get_tree().create_timer(1.0).timeout
	
	
	$DayEndPopup/EmployeeManagement.show();
	$"DayEndPopup/EmployeeManagement/Click to Hire!/AnimationPlayer".play("bounce");
	
	await get_tree().create_timer(3.0).timeout	
	
	$DayEndPopup/NextDay.show();
	
	if Game.days == 6:
		$DayEndPopup/NextDay/NextDayButton.text = "End Week";
	

func update_delivered_babies_label():
	$DayEndPopup/DayEnd/Babies.show();
	$DayEndPopup/DayEnd/Babies/BabiesDeliveredResult.text = str(Game.babies_delivered_today);
	
func update_coins_made_label():
	$DayEndPopup/DayEnd/EarnedToday.show();
	$DayEndPopup/DayEnd/EarnedToday/result.text = str(Game.coins_made_today);

func update_employee_costs_label():
	$DayEndPopup/DayEnd/Costs.show();
	$DayEndPopup/DayEnd/Costs/EmployeeCostsResult.text = str(-Game.get_employee_costs());

func update_total_of_day_label():
	$DayEndPopup/DayEnd/Total.show();
	$DayEndPopup/DayEnd/Total/result.text = str(Game.total_gain_today);





func _on_next_day_button_pressed():
	$ClickSound.play();
	if Game.days == 6:
		get_tree().paused = false;
		SceneManager.change_scene("res://screens/ResultsScreen.tscn");
	else:
		start_next_day();

func start_next_day():
	hide_game_end_panel();
	# reset time to 06:00
	time_of_day = 6 * 60;
	update_time_label();
	
	update_days(Game.days + 1);
	
	Game.coins_made_today = 0;
	Game.babies_delivered_today = 0;
	
	# CONTINUE
	
	get_tree().paused = false;

func update_days(number):
	Game.days = number;
	$TimeArea/DayLabel.text = "day " + str(number + 1) + "/7";
	
	
func hide_game_end_panel():
	$HirePanel.hide();
	$HirePanelBackdrop.hide();
	$WorkerPanel.hide();
	$WorkerPanelBackdrop.hide();
	
	$DayEndPopup.hide();
	
	# hide baby bonus
	$DayEndPopup/DayEnd.hide();
	$DayEndPopup/DayEnd/Babies/BabyBonus.hide();
	$DayEndPopup/DayEnd/Babies.hide();
	$DayEndPopup/DayEnd/EarnedToday.hide();
	$DayEndPopup/DayEnd/Costs.hide();
	$DayEndPopup/DayEnd/Total.hide();
	
	$DayEndPopup/EmployeeManagement.hide();
	$DayEndPopup/NextDay.hide();


func _on_worker_image_click(worker_panel: Button, worker_name):
	selected_worker_panel = worker_panel;
	
	$DayEndPopup/EmployeeManagement/Arrow.hide();
	$"DayEndPopup/EmployeeManagement/Click to Hire!".hide();
	$"DayEndPopup/EmployeeManagement/Click to Hire!/AnimationPlayer".stop();
	
	$ClickSound.play();
	
	if worker_name == Game.WorkerName.none:
		$HirePanel.show();
		$HirePanelBackdrop.show();
	
	else:
		$WorkerPanel.show();
		$WorkerPanelBackdrop.show();
		
		var profile = Game.bird_profiles.get(worker_name);
		
		$WorkerPanel/BirdBio.text = profile.get("bio");
		$WorkerPanel/WorkerName.text = profile.get("name");
		$WorkerPanel/BirdImage.animation = profile.get("key");
		$WorkerPanel/HBoxContainer/FireButton.text = "Fire " + profile.get("name");
		
		$WorkerPanel/HBoxContainer/FireButton.size.x = $WorkerPanel/HBoxContainer/FireButton.get_minimum_size().x;
		

# HIRE PANEL

func _on_hire_button_pressed():
	$ClickSound.play();
	var random_bird_index = randi() % Game.unemployed_birds.size();
	var random_bird_name = Game.WorkerName.values()[Game.unemployed_birds[random_bird_index]];
	
	Game.unemployed_birds.erase(random_bird_name);
	Game.employed_birds.append(random_bird_name);
	
	selected_worker_panel.worker_name = random_bird_name;
	
	const WORKER_PRICE = 100;
	add_to_coins(-WORKER_PRICE);
	
	$HirePanel.hide();
	$HirePanelBackdrop.hide();
	
	create_bird(random_bird_name);

func _on_cancel_button_pressed():
	$ClickSound.play();
	$HirePanel.hide();
	$HirePanelBackdrop.hide();


# FIRE PANEL

func _on_worker_cancel_button_pressed():
	$ClickSound.play();
	$WorkerPanel.hide();
	$WorkerPanelBackdrop.hide();

func _on_fire_button_pressed():
	$ClickSound.play();
	var worker_name = selected_worker_panel.worker_name;
	Game.employed_birds.erase(worker_name);
	Game.unemployed_birds.append(worker_name);
	selected_worker_panel.worker_name = Game.WorkerName.none;
	
	# Remove the bird from the map
	for bird in birds:
		if bird.bird_name == worker_name:
			birds.erase(bird);
			bird.queue_free();
	
	$WorkerPanel.hide();
	$WorkerPanelBackdrop.hide();
	


func add_to_coins(amount_to_change):
	if amount_to_change < 0:
		Game.total_expenses -= amount_to_change;
	elif amount_to_change > 0:
		Game.total_income += amount_to_change;
		
	Game.coins += amount_to_change;
	$BirdCoinGUI/BirdCoinCount.text = str(Game.coins);



func _on_hire_panel_backdrop_pressed():
	$ClickSound.play();
	$HirePanel.hide();
	$HirePanelBackdrop.hide();

func _on_hire_panel_backdrop_button_down():
	$ClickSound.play();
	$HirePanel.hide();
	$HirePanelBackdrop.hide();



func _on_worker_panel_backdrop_pressed():
	$ClickSound.play();
	$WorkerPanel.hide();
	$WorkerPanelBackdrop.hide();

func _on_worker_panel_backdrop_button_down():
	$ClickSound.play();
	$WorkerPanel.hide();
	$WorkerPanelBackdrop.hide();

