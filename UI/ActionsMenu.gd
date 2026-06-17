extends PanelContainer

# VARIABLES ONREADY
@onready var goButton: Button = $MarginContainer/VBoxContainer/GoButton
@onready var lootButton: Button = $MarginContainer/VBoxContainer/LootButton

# VARIABLES
var structureTargetPosition: Vector3
var structureType: String

func _ready() -> void:
	hide()
	goButton.pressed.connect(_on_go_button_pressed)
	lootButton.pressed.connect(_on_button_loot_pressed)
	

func Show_Menu(screenPosition2D: Vector2, structurePosition3D: Vector3, type: String) -> void:
	structureTargetPosition = structurePosition3D
	structureType = type
	
	global_position = screenPosition2D
	show()

func _on_go_button_pressed() -> void:
	Utilities.Print_Message("Moviendose hacia: {type}".format({"type": structureType}))
	hide()

func _on_button_loot_pressed() -> void:
	Utilities.Print_Message("Abriendo Inventario de: {type}".format({"type": structureType}))
	hide()
