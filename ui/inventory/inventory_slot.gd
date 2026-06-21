# inventory_slot.gd
class_name InventorySlot extends PanelContainer

signal slot_clicked(index: int)

@export var itemTexture: TextureRect
var slotItemData: ItemData
var slotIndex: int

func Prepare_Slot(item: ItemData, index: int) -> void:
	slotItemData = item
	slotIndex = index
	itemTexture.texture = item.texture

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		slot_clicked.emit(slotIndex)
