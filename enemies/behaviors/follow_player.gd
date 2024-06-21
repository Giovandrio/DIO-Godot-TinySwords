extends Node

@export var speed: float = 1

var enemy: Enemy
var sprite : AnimatedSprite2D


func _ready():
	
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")
	enemy.health


func _physics_process(delta: float) -> void:	
	
	# Ignorar GAMEOVER
	if GameManager.is_game_over: return
	
	# Calcular Direccion
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position #(0,0) - (x,x)
	var input_vector = difference.normalized() # El input vector requiere de Vector2 (x,y)
	
	# Movimiento
	enemy.velocity = input_vector * speed * 100.0	
	enemy.move_and_slide()
	
	#Girar el sprite	
	if input_vector.x > 0:
		# desmarcar flip_h del Sprite 2D
		sprite.flip_h = false   
	elif input_vector.x < 0:
		#marcar flip_h del Sprite 2D
		sprite.flip_h = true
