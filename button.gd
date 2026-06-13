extends Button
# EXPORTS Y MODULOS
@onready var TextBox = $"../Seed"
@onready var canvas = $"../../../.."
@onready var width = $"../../Coords/Alto"
@onready var depth = $"../../Coords/Ancho"

# FUNCIONES INTEGRADAS
func _ready() -> void:
	pass
	
func _pressed() -> void:
	var Mundo =  Generator.new()
	Mundo.depuration = 1
	Mundo.mapWidth = width.value
	Mundo.mapDepth = depth.value
	Mundo.Generate(TextBox.text, canvas)
