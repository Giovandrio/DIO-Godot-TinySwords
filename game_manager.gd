extends Node

signal game_over

var player: Player
# es un SingleTone que esta arriba del otdo y todos se pueden comunicar con el. Debe estar agregado en AUTOLOAD de settngs
var player_position: Vector2
var is_game_over: bool = false

var time_elapsed: float = 0.0
var time_elapsed_string: String
var meat_counter: int= 0
var monsters_defetad_counter: int = 0


func _process(delta: float):
	# Update Timer
	time_elapsed += delta
	var time_elapsed_in_seconds: int = floori(time_elapsed) #redondar para bajo y devolver INT. Hay round y ceil
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int = time_elapsed_in_seconds / 60	
	# % < para formatear variable, 02< cantidad de digitos,  d < digitos
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]

func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()
	
func reset():
	player = null
	player_position = Vector2.ZERO
	is_game_over = false
	
	time_elapsed= 0.0
	time_elapsed_string = "00:00"
	meat_counter = 0
	monsters_defetad_counter = 0
	
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
