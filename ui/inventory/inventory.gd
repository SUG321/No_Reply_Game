# inventory.gd
class_name InventoryUI extends PanelContainer

signal transfer_requested(itemIdex: int, sourceInventory: Inventory)

# EXPORTS
@export var titleLabel: Label
@export var transferItemButton: Button
@export var itemGrid: GridContainer
@export var inventorySlot: PackedScene

# VARIABLES
var currentInventory: Inventory
var currentIndex: int = 0

var currentPulseTween: Tween
var activeSlot: Control

func _ready() -> void:
	transferItemButton.pressed.connect(_on_transfer_item_button_pressed)

func loadInventory(newInventory: Inventory) -> void:
	titleLabel.text = name
	currentInventory = newInventory
	
	if newInventory.canTransferItems != false:
		transferItemButton.show()
	
	Refresh_UI()

func Refresh_UI() -> void:
	if activeSlot:
		Utilities.Stop_Pulse_UI(activeSlot, currentPulseTween)
	
	Utilities.Clear_Childs(itemGrid, "InventorySlot")
	
	var index: int = 0
	for item: ItemData in currentInventory.items:
		var newInventorySlot: InventorySlot = inventorySlot.instantiate()
		newInventorySlot.add_to_group("InventorySlot")
		itemGrid.add_child(newInventorySlot)
		
		newInventorySlot.Prepare_Slot(item, index)
		newInventorySlot.name = item.displayName + "_" + str(index)
		
		newInventorySlot.slot_clicked.connect(_on_slot_clicked)
		
		index += 1

# FUNCIONES SEÑALES
func _on_slot_clicked(clickedIndex: int) -> void:
	currentIndex = clickedIndex
	transferItemButton.disabled = false
	
	if activeSlot:
		Utilities.Stop_Pulse_UI(activeSlot, currentPulseTween)
	activeSlot = itemGrid.get_child(clickedIndex)
	
	Utilities.Start_Pulse_UI(activeSlot, 0.4)

func _on_transfer_item_button_pressed() -> void:
	transfer_requested.emit(currentIndex, currentInventory)
	transferItemButton.disabled = true
	
	Utilities.Stop_Pulse_UI(activeSlot, currentPulseTween)

# FUNCIONES UTILIDAD
func Restart_Select() -> void:
	if activeSlot:
		Utilities.Stop_Pulse_UI(activeSlot, currentPulseTween)
	transferItemButton.disabled = true
