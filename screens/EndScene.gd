extends Node2D

var success_lines = [
	{
		"type": "line",
		"style": "normal",
		"lines": [
			"Well, well, well! ",
			"Just been away for a little while and you bring the coins in!"
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"That's my grandchild! You're the best!"
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"HOORAY!"
		]
	},
	{
		"type": "line",
		"style": "normal",
		"lines": [
			"Well, time for me to retire anyway. See you next week!"
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"AND DON'T YOU EVER DARE QUITTING!"
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"Thank you for playing!",
		]
	}
];

var average_lines = [
	{
		"type": "line",
		"style": "normal",
		"lines": [
			"Hello, my dear grandchild! ",
			"How did you do this week? "
		]
	},
	{
		"type": "line",
		"style": "normal",
		"lines": [
			"Oh! ",
			"Well, that's not bad. ",
			"Not fantastic either, but not bad."
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"Oh! ",
			"Well, that's not bad. ",
			"Not fantastic either, but not bad at all."
		]
	},
	{
		"type": "line",
		"style": "normal",
		"lines": [
			"I'm sure you'll try again next week.",
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"YOU WILL! NO DISCUSSIONS!",
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"Thank you for playing!",
		]
	},
];

var failure_lines = [
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"What is this??!"
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"How did that happen??",
			"I've only been away for a week!"
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"The only thing you had to do was sending Stan to the babies...",
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"...AAAAAND making sure we don't go under!",
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"What a mess, we've got depts to pay.",
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"...",
		]
	},
	{
		"type": "line",
		"style": "normal",
		"lines": [
			"Well... I hope you try again next week.",
		]
	},
	{
		"type": "line",
		"style": "scream",
		"lines": [
			"Thank you for playing!",
		]
	},
];

# Called when the node enters the scene tree for the first time.
func _ready():
	var babies_delivered = float(Game.babies_delivered_in_total) / 200.0;
	var employed_birds = float(Game.employed_birds.size()) / 8.0;
	var bilanz = float(Game.total_income) / float(max(Game.total_expenses, 1));
	var grade = babies_delivered * employed_birds * bilanz;
	print("grade parts: ", babies_delivered, employed_birds, bilanz);
	print("grade: ", grade);
	
	var lines_to_say = average_lines;
	if grade >= 0.9:
		lines_to_say = success_lines;
	elif grade <= 0.5:
		lines_to_say = failure_lines;
		
	await do_dialog(lines_to_say);
	
	end_game();


func end_game():
	SceneManager.change_scene("res://screens/CreditsScene.tscn");


func do_dialog(lines):
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
		var new_text_length = len(text);
		var old_text_length = len($Speech.text);
		var text_length = old_text_length + new_text_length;
		$Speech.text += text;
		var tween = await get_tree().create_tween();
		tween.tween_property($Speech, "visible_characters", text_length, new_text_length * 0.03).from(old_text_length);
		await tween.finished;
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(1.5).timeout

