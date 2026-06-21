# actions_menu.gd
class_name ActionsMenu extends PanelContainer

# SEÑALES
signal on_navigate_requested(targetPosition3D: Vector3)

# EXPORTS
@export var mouseController: MouseController # CLICKS SIGNALS
@export var human: Human # ON PATH ENDED SIGNAL
@export var goButton: Button # CLICKED SIGNAL
@export var lootButton: Button # CLICKED SIGNAL
@export var lootTimer: Timer # TIMER ENDED SIGNAL
@export var inventoriesManager: InventoriesManager # GESTOR DE INVENTARIOS

# VARIABLES
var structureTargetPosition: Vector3
var structureName: String = ""
var currentStructure: Structure = null

func _ready() -> void:
	hide()
	goButton.pressed.connect(_on_go_button_pressed)
	lootButton.pressed.connect(_on_button_loot_pressed)
	if mouseController:
		mouseController.on_structure_clicked.connect(_on_structure_clicked)
		mouseController.on_click.connect(_on_click)
	inventoriesManager.New_Inventory(human.humanName, Inventory.new(), true)
	inventoriesManager.Hide_Human_Inventory()

func Show_Menu(screenPosition2D: Vector2, structure: Structure) -> void:
	currentStructure = structure
	structureTargetPosition = structure.position
	structureName = structure.structureName
	
	global_position = screenPosition2D
	show()

# FUNCIONES DE SEÑALES
func _on_go_button_pressed() -> void:
	Utilities.Print_Message("Moviendose hacia: " + structureName)
	on_navigate_requested.emit(structureTargetPosition)
	hide()
	await human.on_path_ended

func _on_button_loot_pressed() -> void:
	hide()
	
	on_navigate_requested.emit(structureTargetPosition)
	await human.on_path_ended
	
	lootTimer.start(3)
	Utilities.Print_Message("Saqueando...")
	await lootTimer.timeout
	
	inventoriesManager.Clear_Structure_Inventory()
	inventoriesManager.Show_Human_Inventory()
	
	inventoriesManager.New_Inventory(structureName, currentStructure.inventoryData)

func _on_structure_clicked(structure: Node3D, screenPosition: Vector2) -> void:
	if structure is Structure:
		Show_Menu(screenPosition, structure)
	
func _on_click() -> void:
	hide()
	inventoriesManager.Hide_Human_Inventory()
	inventoriesManager.Clear_Structure_Inventory()
