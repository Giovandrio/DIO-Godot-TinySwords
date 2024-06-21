class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene]
var mobs_per_minute: float = 60.0
@onready var path_follow_2d: PathFollow2D = %PathFollow2D
var cooldown: float = 0.0


func _process(delta: float):
	
	# Ignorar GAMEOVER
	if GameManager.is_game_over: return
	
	# Temporizador (cooldown)
	cooldown -= delta
	if cooldown > 0: return
	
	# Frecuencia : Monstruos por minuto
	# Intervalo en segundos entre monstruos => 60 / Monstruos 
	# 60 / 60 = 1 (cada segundo)
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	# Checar si el punto es valido
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1001 # Layer 1 y Layer 4. Se lee de derecha a izquierdaa
	var result: Array = world_state.intersect_point(parameters, 1)
	if not result.is_empty(): return
	
	
	# Instanciar una criatura Aleatoria
	var index = randi_range(0, creatures.size() -1 )
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = point
	get_parent().add_child(creature) # esto agrega la creatura al arbol de la escena
	
func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf() # dara una posicion aletoria en el path
	return path_follow_2d.global_position # si fuera position dependeria de la posicion de los parents
