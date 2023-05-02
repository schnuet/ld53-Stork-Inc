@tool
extends Button

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

@export var worker_name: WorkerName = WorkerName.none : set = _set_worker_name, get = _get_worker_name;

func _get_worker_name():
	return worker_name;

func _set_worker_name(new_worker_name):
	worker_name = new_worker_name;
	update_image();

signal click;

func update_image():
	var w_name = WorkerName.keys()[worker_name];
	if w_name == "none":
		$WorkerPhoto.animation = "none";
		$Label.visible = true;
	else:
		$WorkerPhoto.animation = w_name;
		$Label.visible = false;


func _on_pressed():
	emit_signal("click", self, worker_name);
