extends Control

# MODULOS ONREADY
	# GENERATOR PANEL
@onready var map3D = $"../../Map"
@onready var button = $Panel/MarginContainer/VBoxContainer/Seed/Button
@onready var seedText = $Panel/MarginContainer/VBoxContainer/Seed/Seed
@onready var widthRange = $Panel/MarginContainer/VBoxContainer/Coords/Alto
@onready var depthRange = $Panel/MarginContainer/VBoxContainer/Coords/Ancho

	# MESSAGES PANEL
@onready var messagesTextBox = $MessagesPanel/MarginContainer/MessagesTextBox

# FUNCIONES INTEGRADAS
func _ready() -> void:
	button.pressed.connect(_on_button_pressed) # CONECCION A SEÑAL: BOTON PRESIONADO
	Utilities.connect("signalMessage", _on_message_emit) # CONECCION A SEÑAL: MENSAJE EMITIDO POR CLASE UTILITIES

# SEÑALES
func _on_button_pressed() -> void: # FUNCION: BOTON PRESIONADO
	
	var depth :int = widthRange.value
	var width :int = depthRange.value
	
	var world =  Generator.new()
	world.mapWidth = depth
	world.mapDepth = width
	world.Generate(seedText.text, map3D)
	
	map3D.Initialize_Navigation(world.map, depth, width)

func _on_message_emit(message: String) -> void:
	messagesTextBox.text = message
