# structure_data.gd
class_name StructureData extends Item_Structure

@export var id: String = ""
@export var displayName: String = ""
@export var texture: Texture2D
@export var spawnWeight: int = 10
@export var solid: bool = false

@export_group("Reglas de Saqueo")
@export var lootAmount: int = 10
@export var lootLimit: int = 8
