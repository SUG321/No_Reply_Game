# inventories_manager.gd
class_name InventoriesManager extends VBoxContainer

@export var inventoryScene: PackedScene

var humanInventoryUI: InventoryUI = null
var structureInventoryUI: InventoryUI = null

func New_Inventory(inventoryName: String, inventoryData: Inventory, isHuman: bool = false) -> InventoryUI:
	var newInventory: InventoryUI = inventoryScene.instantiate()
	newInventory.name = inventoryName
	add_child(newInventory)
	newInventory.loadInventory(inventoryData)
	
	newInventory.transfer_requested.connect(_on_transfer_requested)
	
	if isHuman:
		humanInventoryUI = newInventory
	else:
		structureInventoryUI = newInventory
	
	return newInventory

# FUNCIONES DE SEÑALES
func _on_transfer_requested(itemIndex: int, sourceInventory: Inventory) -> void:
	if humanInventoryUI == null and structureInventoryUI == null:
		return
	
	var targetInventory: Inventory = null
	
	if sourceInventory == humanInventoryUI.currentInventory:
		targetInventory = structureInventoryUI.currentInventory
	else:
		targetInventory = humanInventoryUI.currentInventory
	
	if not sourceInventory.canDropItems or not targetInventory.canGetItems:
		Utilities.Print_Message("Accion no permitida (como lograste eso?...)")
		return
	
	var itemToTransfer = sourceInventory.remove_item(itemIndex)
	
	if itemToTransfer != null:
		targetInventory.add_item(itemToTransfer)
		
		humanInventoryUI.Refresh_UI()
		structureInventoryUI.Refresh_UI()

# FUNCIONES DE UTILIDAD
func Hide_Human_Inventory() -> void:
	if is_instance_valid(humanInventoryUI):
		humanInventoryUI.hide()

func Show_Human_Inventory() -> void:
	if is_instance_valid(humanInventoryUI):
		humanInventoryUI.show()

func Clear_Structure_Inventory() -> void:
	if is_instance_valid(structureInventoryUI):
		structureInventoryUI.queue_free()
		structureInventoryUI = null
