extends Control

# MODULOS ONREADY
@onready var map3D = $"../../Map"
@onready var button = $Panel/MarginContainer/VBoxContainer/Seed/Button
@onready var seedText = $Panel/MarginContainer/VBoxContainer/Seed/Seed
@onready var widthRange = $Panel/MarginContainer/VBoxContainer/Coords/Alto
@onready var depthRange = $Panel/MarginContainer/VBoxContainer/Coords/Ancho

# FUNCIONES INTEGRADAS
func _ready() -> void:
	button.pressed.connect(_on_button_pressed) # CONECCION A SEÑAL: BOTON PRESIONADO

# SEÑALES
func _on_button_pressed() -> void: # FUNCION: BOTON PRESIONADO
	
	var width :int = widthRange.value
	var depth :int = depthRange.value
	
	var world =  Generator.new()
	world.mapWidth = width
	world.mapDepth = depth
	world.Generate(seedText.text, map3D)
	
	map3D.Initialize_Navigation(world.map, width, depth)
