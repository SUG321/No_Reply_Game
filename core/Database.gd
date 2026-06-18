extends Node

var structures: Dictionary = {
	"bulding": preload("res://structures/resources/structure_building.tres"),
	"house": preload("res://structures/resources/structure_house.tres"),
	"house_boarded": preload("res://structures/resources/structure_house_boarded.tres"),
	"well": preload("res://structures/resources/structure_well.tres"),
	"camp": preload("res://structures/resources/structure_camp.tres"),
	"bunker": preload("res://structures/resources/structure_bunker.tres"),
	"corpse": preload("res://structures/resources/structure_corpse.tres"),
	"Null": preload("res://structures/resources/structure_Null.tres")
}

var items: Dictionary = {
	"trash": preload("res://items/resources/item_trash.tres"),
	"components": preload("res://items/resources/item_components.tres"),
	"metal": preload("res://items/resources/item_metal.tres"),
	"bag": preload("res://items/resources/item_bag.tres"),
	"clothes": preload("res://items/resources/item_clothes.tres"),
	"backpack": preload("res://items/resources/item_backpack.tres"),
	"weapon": preload("res://items/resources/item_weapon.tres"),
	"food": preload("res://items/resources/item_food.tres"),
	"meds": preload("res://items/resources/item_meds.tres"),
	"Null": preload("res://items/resources/item_null.tres")
}

func Get_Item(id: String) -> ItemData:
	if items.has(id):
		return items[id]
	push_error("El item " + id + " no existe.")
	return null
