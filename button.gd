extends Button
# EXPORTS Y MODULOS
@onready var TextBox = $"../Seed"
@onready var canvas = $"../../.."

# SEÑALES
signal World(Generated);

# FUNCIONES INTEGRADAS
func _ready() -> void:
	pass
	
func _pressed() -> void:
	World.emit(Generator.Generate(TextBox.text, canvas))
	pass
	
