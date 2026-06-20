# cell_data.gd
class_name MapCell extends RefCounted

@export var structure: StructureData
@export var loot: Array[ItemData] = []
