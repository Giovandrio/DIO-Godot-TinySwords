extends Node

@export var game_ui: CanvasLayer
@export var game_over_ui_template: PackedScene

func _ready():
	GameManager.game_over.connect(trigger_gameover)

func trigger_gameover():
	
	#Eleminar GameUI
	if game_ui:
		game_ui.queue_free()	
		game_ui = null
		
	#Crear GameOverUI
	var game_over_ui: GameOverUI= game_over_ui_template.instantiate()
	add_child(game_over_ui)
