# inventory_data.gd
class_name Inventory extends Resource

# REGLAS DE INVENTARIO
@export var canGetItems: bool = true
@export var canDropItems: bool = true

# INVENTARIO
@export var items: Array[ItemData] = []

# FUNCIONES DE INVENTARIO
func add_item(item) -> bool:
	if not canGetItems:
		return false
	items.append(item)
	return true

func remove_item(index: int) -> ItemData:
	if not canDropItems or index >= items.size():
		return null
	var item: ItemData = items[index]
	items.remove_at(index)
	return item
