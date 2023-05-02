extends AudioStreamPlayer

var current_music_name = "";

# register and preload your music streams here:
var music_streams = {
	"main": preload("res://music/stork-inc-maintheme.ogg"),
};

func _ready():
	for stream_name in music_streams:
		var stream = music_streams.get(stream_name);
		stream.loop = true;

func play_music(music_name:String):
	if current_music_name == music_name:
		return;
	
	stop();
	
	current_music_name = music_name;
	stream = music_streams.get(current_music_name);
	
	play();
	
func register_stream(stream_path:String, music_name:String):
	music_streams[music_name] = load(stream_path);
