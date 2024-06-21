class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3

@export_category("Sword")
@export var sword_damage: int = 2

@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene

@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var dead_prefab: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer #tipo de var AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var healt_progress_bar: ProgressBar = $HealthProgressBar

var input_vector: Vector2 = Vector2 (0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

signal meat_collected(value: int)

func _ready():
	GameManager.player =  self
	meat_collected.connect(func(value: int): GameManager.meat_counter +=1)

func _process(delta) -> void: #esto procesa cada delta. para moviemeinto el _phsysics_prucess es mas preciso
	
	#esta linea conecta con el SingleTone GameManager. 
	GameManager.player_position = position
	
	# leer Input	
	read_input()
	
	# Procesar ataque
	update_attack_cooldown(delta)
	
	# Ataque
	if Input.is_action_just_pressed("attack"):
		attack()		
	
	# Procesar animacion y rotacion sprite
	play_run_idle_animation()
	if not is_attacking: # Pdddsara que no rote cuando esta atacando
		rotate_sprite()
	
	# Procesar Daño
	update_hitbox_detection(delta)
	
	# Ritual
	update_ritual(delta)	
	# Actualizar Health Bar	
	healt_progress_bar.max_value = max_health
	healt_progress_bar.value = health
			
func _physics_process(delta: float) -> void:
		
	# Modificar Velocidad
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25		
	velocity = lerp(velocity, target_velocity, 0.6)
	move_and_slide()
		
func read_input() -> void:
	
	#Obtener el Input Vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down") # Lo ultimo es el deadzone
	
	#Apagar deadzone de input vector
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0			
		
	#Actulizar is_runing	
	was_running = is_running
	is_running = not input_vector.is_zero_approx() #solo corre si el valor del  vector NO fuera zero
	
func update_attack_cooldown(delta: float) -> void:
	
	# Actualizar temporizador de ataque
	if attack_cooldown > 0:
		attack_cooldown -= delta #0.6 -0.016(delta) 60 cuadros por segundo)
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")
			
func update_ritual(delta: float) -> void:
	
	# Actualizar temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0 : return
	ritual_cooldown = ritual_interval
	
	# Crear Ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual) # La posicion del ritual es 0,0 Eso como child de player
	
func play_run_idle_animation() -> void:
	
	# Tocar Animacion
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")						
			else:
				animation_player.play("idle")		
		
func rotate_sprite() -> void:
	
	#Girar el sprite	
	if input_vector.x > 0:
		# desmarcar flip_h del Sprite 2D
		sprite.flip_h = false   
	elif input_vector.x < 0:
		#marcar flip_h del Sprite 2D
		sprite.flip_h = true
		
func attack() -> void:
	#if is_attacking:  #si esta atacando sale del codigo, regresa.
	#return
	
	animation_player.play("attack_side_1")
	
	#Configuracion de temporizador
	attack_cooldown = 0.6 # despues que se ejecuta la animacion se le dan 6 milisegundos que iran bajando .016 cada delta
	
	#Marccar ataque
	is_attacking = true

func deal_damage_to_enemies() -> void:
	
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized() #normalizar es de vector (x,y) a 0.5456 un solo nnumero
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else :
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction) # el dot product, segun las posiciones determina si es (1 0 -1) Normalizado	
			if dot_product >= 0.5:
				enemy.damage(sword_damage)
	
	#var enemies = get_tree().get_nodes_in_group("enemies") # el tree son todos los elementos de la Scene
	#for enemy in enemies:
		#enemy.damage(sword_damage) #la funcion de damage del enemigo y por parametro se le pasa sword_damage
	
func update_hitbox_detection (delta: float) -> void:
	
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	# Frecuencia (2x por segundo)
	hitbox_cooldown = 0.5
	
	
	# Detectar Enemigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)
			
	pass
	
		
func damage(amount: int) -> void:
	
	if health <= 0: return
	
	health -= amount
	print("Player recibio dano de ", amount," La vida total es de ", health)
	
	# Piscar Node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(tween.EASE_IN) # easings.net
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	
	# Processar morte
	if health <= 0:
		die()
		
func die() -> void:
	
	GameManager.end_game()
	
	if dead_prefab:
		var death_object = dead_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object) # Para crear este objeto en la escena
	
	print("Player Murio")	
	queue_free()	
		
func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Player recibio cura de ", amount, " La vida total es de ", health, "/", max_health)	
	return health
