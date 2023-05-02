extends Node2D


var lines = [
	{
		"type": "line",
		"style": "normal", 
		"lines": [
			"So... ",
			"welcome to Stork inc., old pal!"
		]
	},
	{
		"type": "action", 
		"action": turn_on_light,
	},
	{
		"type": "line",
		"style": "normal", 
		"lines": [
			"This is your office this week! ",
			"I’m sure you’ll do a fabulous job, my grandchild."
		]
	},
	{
		"type": "line",
		"style": "normal", 
		"lines": [
			"You won’t fail me. ", 
			"Like your brother."
		]
	},
	{
		"type": "line",
		"style": "normal", 
		"lines": ["Or your sister."]
	},
	{
		"type": "line",
		"style": "scream", 
		"lines": [
			"You’d better not! ",
			"Last chance for your lot!"
		]
	},
	{
		"type": "line",
		"style": "normal", 
		"lines": [
			"So, what do we do here? ", 
			"Of course! ",
			"We deliver babies!"
		]
	},
	{
		"type": "line",
		"style": "normal", 
		"lines": [
			"It’s actually really easy! ",
			"Just pick up the child and bring it to a mother."
		]
	},
	{
		"type": "line",
		"style": "scream", 
		"lines": ["BUT DON’T DO IT YOURSELF!"]
	},
	{
		"type": "line",
		"style": "normal", 
		"lines": [
			"Just tell Stan. ",
			"He knows how to. ",
			"Send him to a baby and he’ll find the way."
		]
	},
	{
		"type": "line",
		"style": "normal", 
		"lines": [
			"We get Birdcoins for every baby! ", 
			"The more, the better. ", 
			"We have to pay our birds, after all."
		]
	},
	{
		"type": "line",
		"style": "scream", 
		"lines": ["SO DON’T MESS IT UP!"]
	},
	{
		"type": "line",
		"style": "normal", 
		"lines": [
			"I’ll be back in a week. ",
			"Let’s see how well you do till then."
		]
	},
	{
		"type": "line",
		"style": "scream", 
		"lines": ["GOOD LUCK!"]
	},
];

# Called when the node enters the scene tree for the first time.
func _ready():
	await do_dialog();
	
	start_game();


func do_dialog():
	$Panel.show();
	$Speech.show();
	for line in lines:
		if line.get("type") == "line":
			await update_speech(line);
		elif line.get("type") == "action":
			await line.get("action").call()
			
	
	$Panel.hide();
	$Speech.hide();

func update_speech(line):
	var texts = line.get("lines");
	$Speech.visible_characters = 0;
	$Speech.text = "";
	
	if line.get("style") == "scream":
		$Gramps.animation = "scream";
		$Speech.uppercase = true;
	else:
		$Gramps.animation = "normal";
		$Speech.uppercase = false;
	
	for text in texts:
		print("next line!");
		var new_text_length = len(text);
		var old_text_length = len($Speech.text);
		var text_length = old_text_length + new_text_length;
		$Speech.text += text;
		var tween = await get_tree().create_tween();
		tween.tween_property($Speech, "visible_characters", text_length, new_text_length * 0.03).from(old_text_length);
		await tween.finished;
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(1.5).timeout

func turn_on_light():
	print("turn_on_lights")
	

func start_game():
	Game.days = 0;
	Game.coins = 0;
	
	Game.coins_made_today = 0;
	Game.babies_delivered_today = 0;
	Game.total_gain_today = 0;

	Game.babies_delivered_in_total = 0;
	Game.total_expenses = 0;
	Game.total_income = 0;
	
	Game.available_animal_types = [
		Game.ANIMAL_TYPE.rabbit
	];

	Game.employed_birds = [Game.WorkerName.stan];
	Game.unemployed_birds = [
		Game.WorkerName.harvey,
		Game.WorkerName.bob,
		Game.WorkerName.bringsitnow,
		Game.WorkerName.eduardo,
		Game.WorkerName.rose,
		Game.WorkerName.gaga,
		Game.WorkerName.sunny
	];
	
	SceneManager.change_scene("res://scenes/main_map.tscn");

func _on_skip_button_pressed():
	start_game();
