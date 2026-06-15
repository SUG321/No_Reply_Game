extends Node3D

# MODULOS ONREADY
@onready var human :Human = $"../Human"
@onready var camera :Camera3D = $"../Camera3D"

# ASTARGRID
var astarGrid :AStarGrid2D

# FUNCIONES DE ASTARGRID
func Initialize_Navigation(map: Dictionary , width: int, height: int) -> void:
	var numberOfSolids = 0 # DEPURACION
	width *= int(Config.cellSize)
	height *= int(Config.cellSize)
	
	astarGrid = AStarGrid2D.new()
	
	astarGrid.region = Rect2i(0, 0, width, height)
	astarGrid.cell_size = Vector2(1, 1)
	
	astarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astarGrid.update()
	
	for cell in map:
		var location = map[cell]["structure"]
		
		if location == "building" or location == "house" or location == "house_boarded" or location == "bunker":
			astarGrid.set_point_solid(cell, true)
			numberOfSolids += 1
			
	# DEPURACION ---------------------------------------------
	if Config.depuration >= 1: 
		var total_celdas_grid = width * height
		print("\n[map.gd/Initialize_Navigation]: --- REPORTE DE ASTARGRID ---")
		print("- Dimensiones de la cuadrícula: ", width, "x", height)
		print("- Celdas totales de navegación: ", total_celdas_grid)
		print("- Objetos sólidos (bloqueos) registrados: ", numberOfSolids)
		print("- Celdas libres para caminar: ", (total_celdas_grid - numberOfSolids))
		print("--------------------------------------------------")
	# FIN DEPURACION -----------------------------------------
	
	human.global_position = Vector3(0, 0, 0)

func Get_Route(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	if astarGrid.is_point_solid(end):
		print("[GAMEPLAY]: No se puede llegar a ese lugar...")
		return []
	
	var route = astarGrid.get_id_path(start, end)
	return route

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var plane = Plane(Vector3.UP, 0.0)
		var mousePosition = event.position
		
		var rayOrigin = camera.project_ray_origin(mousePosition)
		var rayDirection = camera.project_ray_normal(mousePosition)
		
		var intersectionPoint = plane.intersects_ray(rayOrigin, rayDirection)
		
		if intersectionPoint != null:
			var destinyCell = Vector2i(
				round(intersectionPoint.x),
				round(intersectionPoint.z / Config.cellSize)
			)
			
			var cellStart = Vector2i(
				round(human.global_position.x),
				round(human.global_position.z / Config.cellSize)
			)
			
			print("start: ", cellStart, " | final: ", destinyCell)
			
			var route = Get_Route(destinyCell, cellStart)
			print("route: ", route)
			human.Follow_Route(route)
