extends PanelContainer
class_name ActionsMenu

# SEÑALES
signal on_navigate_requested(targetPosition3D: Vector3)

# EXPORTS Y VARIABLES ONREADY
@export var mouseController: MouseController
@onready var goButton: Button = $MarginContainer/VBoxContainer/GoButton
@onready var lootButton: Button = $MarginContainer/VBoxContainer/LootButton

# VARIABLES
var structureTargetPosition: Vector3
var structureType: String

func _ready() -> void:
	hide()
	goButton.pressed.connect(_on_go_button_pressed)
	lootButton.pressed.connect(_on_button_loot_pressed)
	if mouseController:
		mouseController.on_structure_clicked.connect(_on_structure_clicked)
		mouseController.on_click.connect(_on_click)

func Show_Menu(screenPosition2D: Vector2, structurePosition3D: Vector3, type: String) -> void:
	structureTargetPosition = structurePosition3D
	structureType = type
	
	global_position = screenPosition2D
	show()

# FUNCIONES DE SEÑALES
func _on_go_button_pressed() -> void:
	Utilities.Print_Message("Moviendose hacia: {type}".format({"type": structureType}))
	on_navigate_requested.emit(structureTargetPosition)
	hide()
func _on_button_loot_pressed() -> void:
	Utilities.Print_Message("Abriendo Inventario de: {type}".format({"type": structureType}))
	hide()
func _on_structure_clicked(structureNode: Node3D, screenPosition: Vector2) -> void:
	Show_Menu(screenPosition, structureNode.global_position, structureNode.name)
func _on_click() -> void:
	hide()
