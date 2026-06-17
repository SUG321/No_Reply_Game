extends Node3D

# EXPORTS
@export var actionsMenu: PanelContainer
@export var camera: Camera3D
@export var human: Human

# ASTARGRID
var astarGrid :AStarGrid2D

# VARIABLES
var solidStructures :Array[Vector2i]

# FUNCIONES DE ASTARGRID
func Initialize_Navigation(map: Dictionary , width: int, height: int) -> void:
	var numberOfSolids = 0 # DEPURACION
	
	astarGrid = AStarGrid2D.new()
	
	astarGrid.region = Rect2i(0, 0, width, height)
	astarGrid.cell_size = Vector2(1, 1)
	
	astarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astarGrid.update()
	
	for cell in map:
		var location = map[cell]["structure"]
		
		if location == "building" or  location == "house" or location == "house_boarded" or location == "bunker":
			astarGrid.set_point_solid(cell, true)
			solidStructures.append(cell)
			numberOfSolids += 1
	
	human.solidStructures = solidStructures
	
	# POR SI EL JUGADOR SE GENERA EN UN OBJETO SOLIDO
	var securePositionFound = false
	
	for x in range(width):
		for y in range(height):
			var actualCell = Vector2i(x, y)
			
			if not astarGrid.is_point_solid(actualCell):
				human.global_position = Vector3(
					actualCell.x * Config.cellSize,
					human.global_position.y,
					actualCell.y * Config.cellSize
				)
				securePositionFound = true
				break
				
		if securePositionFound:
			break
	
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

func Get_Route(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	if astarGrid.is_point_solid(end):
		Utilities.Print_Message("Estructura detectada. Caminando...")
		end = Get_Free_Adyacent_Cell(end, start)
		
		if astarGrid.is_point_solid(end):
			Utilities.Print_Message("La estructura esta rodeada imposible llegar...")
			return []
	
	var route = astarGrid.get_id_path(start, end)
	if route.size() == 0:
		Utilities.Print_Message("Imposible de llegar...")
	
	return route

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var mousePosition = event.position
		
		var rayOrigin = camera.project_ray_origin(mousePosition)
		var rayDirection = camera.project_ray_normal(mousePosition)
		
		# RAYCAST 3D ------------------------------
		var spaceState = get_world_3d().direct_space_state
		var rayEnd = rayOrigin + rayDirection * 2000.0
		var query = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
		query.collide_with_areas = true
		
		var result = spaceState.intersect_ray(query)
		
		if result and result.collider.is_in_group("structures"):
			var collidedObject = result.collider
			var position2D = camera.unproject_position(collidedObject.global_position)
			
			actionsMenu.Show_Menu(position2D, collidedObject.global_position, collidedObject.name)
			return
		# FINAL RAYCAST 3D -------------------------
		
		if actionsMenu.visible:
			actionsMenu.hide()
		
		var plane = Plane(Vector3.UP, 0.0)
		var intersectionPoint = plane.intersects_ray(rayOrigin, rayDirection)
		
		if intersectionPoint != null:
			var destinyCell = Vector2i(
				round(intersectionPoint.x / Config.cellSize),
				round(intersectionPoint.z / Config.cellSize)
			)
			
			if astarGrid != null:
				if not astarGrid.is_in_boundsv(destinyCell):
					Utilities.Print_Message("El lugar al que intentas ir está fuera de los límites del mapa.")
					return
			
				var cellStart = Vector2i(
					round(human.global_position.x / Config.cellSize),
					round(human.global_position.z / Config.cellSize)
				)
				
				var route = Get_Route(cellStart, destinyCell)
			
				# DEPURACION ---------------------------------------------
				if Config.depuration >= 2:
					print("\n[map.gd/_unhandled_input]: --- NUEVO CLIC DETECTADO ---")
					print("- Coordenada Real 3D  : X: ", snapped(intersectionPoint.x, 0.1), ", Z: ", snapped(intersectionPoint.z, 0.1))
					print("- Traducido a Celda   : ", destinyCell)
					print("- Inicio del Personaje: ", cellStart)
					
					if route.is_empty():
						print("- ESTADO DE RUTA: AStarGrid devolvió [] (Destino bloqueado o inalcanzable)")
					else:
						print("- ESTADO DE RUTA: Ruta trazada exitosamente.")
					print("------------------------------------------------------------------")
				# FIN DEPURACION -----------------------------------------
				
				human.Follow_Route(route)

func Get_Free_Adyacent_Cell(targetCell: Vector2i, actualPlayerCell: Vector2i) -> Vector2i:
	var directions = [
		Vector2i(0, 1),		# ABAJO
		Vector2i(0, -1),	# ARRIBA
		Vector2i(1, 0),		# DERECHA
		Vector2i(-1, 0)		# IZQUIERDA
		#Vector2i(1, 1),	# ESQUINA INFERIOR DERECHA
		#Vector2i(1, -1),	# ESQUINA SUPERIOR DERECHA
		#Vector2i(-1, 1),	# ESQUINA INFERIOR IZQUIERDA
		#Vector2i(-1, -1)	# ESQUINA SUPERIOR IZQUIERDA
	]
	
	var bestCell = targetCell
	var minimumDistance = INF
	
	var foundCell = false
	for direction in directions:
		var nearbyCell = targetCell + direction
		
		if astarGrid.is_in_boundsv(nearbyCell) and not astarGrid.is_point_solid(nearbyCell):
			var distance = actualPlayerCell.distance_to(nearbyCell)
			
			if distance < minimumDistance:
				minimumDistance = distance
				bestCell = nearbyCell
				foundCell = true
				
	if foundCell:
		return bestCell
	else:
		return targetCell
