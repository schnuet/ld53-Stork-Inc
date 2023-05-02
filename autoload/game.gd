extends Node2D

var coins = 0;
var days = 0;

var coins_made_today = 0;
var babies_delivered_today = 0;

var total_gain_today = 0;

var stork_facts = [
	"Storks can use tools!",
	"Storks attract mates by dancing!",
	"A group of storks is called a 'muster'!",
	"Storks can digest poison!",
	"Storks can reuse their nests!",
	"Storks sleep on one leg!",
	"Stork nests can weight up to a ton!"
];

var babies_delivered_in_total = 0;
var total_expenses = 0;
var total_income = 0;

enum MARKER_TYPE { START, END };
enum ANIMAL_TYPE { fox, rabbit, cat, dog, sheep, bear };

enum WorkerName {
	none,
	stan,
	harvey, # sonnenbrille
	bob, # taube
	bringsitnow, # seriös
	eduardo, # alter postbote
	rose, # süßigkeiten
	gaga, # gossip girl
	sunny # sonnige
};

var available_animal_types = [
	ANIMAL_TYPE.rabbit
];

var employed_birds = [WorkerName.stan];
var unemployed_birds = [
	WorkerName.harvey,
	WorkerName.bob,
	WorkerName.bringsitnow,
	WorkerName.eduardo,
	WorkerName.rose,
	WorkerName.gaga,
	WorkerName.sunny
];

var bird_profiles = {
	WorkerName.harvey: {
		"key": "harvey",
		"name": "Harvey",
		"bio": "Harvey and his Harley are well known in the whole town. A dude too cool for school but just right to work in baby deliveries!"
	},
	WorkerName.bob: {
		"key": "bob",
		"name": "Bob",
		"bio": "Bob is a normal stork that lives a normal boring stork life with normal stork dreams that are in no way suspicious. We like bob."
	},
	WorkerName.bringsitnow: {
		"key": "bringsitnow",
		"name": "Sir Bringsitnow",
		"bio": "Never have a seen a stork more elegant and humble as the great man that is known as Sir Bringsitnow! O how lucky am I to have know this gentleman."
	},
	WorkerName.eduardo: {
		"key": "eduardo",
		"name": "Eduardo",
		"bio": "Eduardo has been working for at least twelve years as a delivery man. When he comes home, he always entertains his kids with old stories from his jobs."
	},
	WorkerName.rose: {
		"key": "rose",
		"name": "Rose",
		"bio": "Rose is a sweet loving lady-bird. She has seven hamsters. Every morning, she likes to go an walk to meet her old friend Marlo, with whom she has yoga classes."
	},
	WorkerName.gaga: {
		"key": "gaga",
		"name": "Gaga",
		"bio": "Gaga (aka the Gossip Girl) knows everyone, their dogs and their secrets! No one could be more amicable than her. And if you need the latest news? Ask her!"
	},
	WorkerName.sunny: {
		"key": "sunny",
		"name": "Sunny",
		"bio": "Sunny wants to help every baby! She has big dreams for the world and can’t wait to meet everyone."
	},
	WorkerName.stan: {
		"key": "stan",
		"name": "Stan",
		"bio": "Our most loyal, hardworking stork! How would this company ever have worked if old Stan didn’t help out wherever he could?"
	},
};

const EMPLOYEE_COSTS = 50;

func get_employee_costs():
	return EMPLOYEE_COSTS * employed_birds.size();

func get_baby_bonus():
	return floori(babies_delivered_today * 2);
