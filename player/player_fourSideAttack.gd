extends CharacterBody2D

@export var speed: float = 3
@onready var animation_player: AnimationPlayer = $AnimationPlayer #tipo de var AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var is_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0

func _process(delta) -> void: #esto procesa cada delta. para moviemeinto el _phsysics_prucess es mas preciso
	# Actualizar temporizador de ataque
	if attack_cooldown > 0:
		attack_cooldown -= delta #0.6 -0.016(delta) 60 cuadros por segundo)
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")


func _physics_process(delta: float) -> void:
	#Obtener el Input Vector
	var  input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down") # Lo ultimo es el deadzone
	
	#Apagar deadzone de input vector
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0	
	
	# Modificar Velocidad
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.02
		
	velocity = lerp(velocity, target_velocity, 0.6)
	move_and_slide()
	
	#Actulizar is_runing	
	var was_running = is_running
	is_running = not input_vector.is_zero_approx() #solo corre si el valor del  vector NO fuera zero
	
	# Tocar Animacion
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")						
			else:
				animation_player.play("idle")	
			
	#Girar el sprite	
	if input_vector.x > 0:
		# desmarcar flip_h del Sprite 2D
		sprite.flip_h = false   
	elif input_vector.x < 0:
		#marcar flip_h del Sprite 2D
		sprite.flip_h = true
		
		
		#Ataque
	if Input.is_action_just_pressed("attack"):
		attack()
		
func attack() -> void:
	#if is_attacking:  #si esta atacando sale del codigo, regresa.
		#return
		
		var  input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		#Tocar animacion
		
		var deadzone = 0.35
		if abs(input_vector.x) < deadzone:
			input_vector.x = 0.0
		if abs(input_vector.y) < deadzone:
			input_vector.y = 0.0	
		
		if input_vector.y == 0: #>>>>>######################## CODIGO ORIGINAL (solo esto es)
			animation_player.play("attack_side_1")
			
		#Configuracion de temporizador
			attack_cooldown = 0.6 # despues que se ejecuta la animacion se le dan 6 milisegundos que iran bajando .016 cada delta		
		#Marccar ataque
			is_attacking = true
		# CODIGO ORGINAL <<<<<<<<<<<<<<<<<<<<<<<#########
		
		
		elif input_vector.y < 0:
			
			animation_player.play("attack_up_1")
			
			#Configuracion de temporizador
			attack_cooldown = 0.5 # despues que se ejecuta la animacion se le dan 6 milisegundos que iran bajando .016 cada delta		
			#Marccar ataque
			is_attacking = true
			
		elif input_vector.y > 0:
			
			animation_player.play("attack_down_1")
			
			#Configuracion de temporizador
			attack_cooldown = 0.6 # despues que se ejecuta la animacion se le dan 6 milisegundos que iran bajando .016 cada delta		
			#Marccar ataque
			is_attacking = true	
			

	
	














""" Anterior solo para activar y desactivar el idle
func _process(delta: float):
	if Input.is_action_just_pressed("move_up"):
		if is_running:
			animation_player.play("idle")
			is_running = false
		else:
			animation_player.play("run")
			is_running= true
"""			
