class_name Generator
extends RefCounted

# MAQUINAS
var rng :RandomNumberGenerator = RandomNumberGenerator.new()
var noise :FastNoiseLite = FastNoiseLite.new()

# ESCENAS
var locationScene :PackedScene = preload("res://assets/scenes/location.tscn")

# Variables
var mapWidth :int = 10 # X
var mapDepth :int = 10 # Z
var map :Dictionary = {}

# DICCIONARIOS
var locationsTextures :Dictionary = ObjDictionary.StructuresTexts # Texturas
var locations :Array = ObjDictionary.Structures # Estructuras
var objects :Array = ObjDictionary.Items # Objetos
var limits :Array = ObjDictionary.Dificults # Limites de Peso

# FUNCIONES DE MAPA
func Generate(Seed: String, world: Node3D) -> void:
	var _Seed = Seed.hash()
	rng.seed = _Seed
	noise.seed = _Seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.08
	
	Generate_Heat_Map(mapDepth, mapWidth)
	Generate_3D_World(world)


func Generate_Heat_Map(width: int, height: int):
	# DEPURACION ---------------------------------------------
	if Config.depuration>= 2: print("\n[generator.gd/Generate_Heat_Map]: ...INIT GEN MAPA")
	# FIN DEPURACION -----------------------------------------
	map.clear()
	var uniquePositions = {}
	
	for y in range(height):
		var fila = ""
		for x in range(width):
			var value = noise.get_noise_2d(x, y)
			var cellBudget = 0
			var icon = ""
			
			if value > 0.3:
				cellBudget = 80
				# DEPURACION ---------------------------------------------
				if Config.depuration >= 2: icon = "██"
			elif value > 0.0:
				cellBudget = 30
				# DEPURACION ---------------------------------------------
				if Config.depuration >= 2: icon += "▒▒"
			else:
				cellBudget = 10
				# DEPURACION ---------------------------------------------
				if Config.depuration >= 2: icon += ".."
			
			fila += icon
			
			var generatedLocations = Generate_Entities(cellBudget, locations)
			if generatedLocations.size() > 0:
				var principalLocation = generatedLocations[0]
				var locationName = principalLocation["name"]
				
				if locationName != "Null":
					var minimumDistance = 0
					
					if locationName == "well":
						minimumDistance = 20
					elif locationName == "bunker":
						minimumDistance = 30
					elif locationName == "camp":
						minimumDistance = 10
					elif locationName == "house_boarded":
						minimumDistance = 20
					
					var veryClose = false
					if minimumDistance > 0:
						if uniquePositions.has(locationName):
							for position in uniquePositions[locationName]:
								if position.distance_to(Vector2(x, y)) < minimumDistance:
									veryClose = true
									break
					
					if veryClose:
						locationName = "Null"
					else:
						if minimumDistance > 0:
							if not uniquePositions.has(locationName):
								uniquePositions[locationName] = []
							uniquePositions[locationName].append(Vector2(x, y))
				
				if locationName != "Null":
					var generatedObjects = Generate_Entities(principalLocation["loot"], objects)
					var lootList = []
					for object in generatedObjects:
						lootList.append(object["name"])
					map[Vector2(x, y)] = {
						"structure": principalLocation["name"],
						"loot": lootList
					}
		# DEPURACION ---------------------------------------------
		if Config.depuration >= 2: print(fila)
		# FIN DEPURACION ----------------------------------------- 
	
	# DEPURACION ---------------------------------------------
	if Config.depuration >= 1: 
		var totalCells = width * height
		print("\n[generator.gd/Generate_Heat_Map]: --- REPORTE DEL MAPA DE CALOR ---")
		print("- Dimensiones: ", width, "x", height)
		print("- Total de celdas analizadas: ", totalCells)
		print("- Estructuras válidas generadas: ", map.size())
		print("--------------------------------------------------")
	# FIN DEPURACION -----------------------------------------

func Generate_Entities(budget: int, list: Array) -> Array:
	var totalWeight = 0;
	var _Selection = [];
	
	for i in range(list.size()):
		totalWeight += list[i]["weight"];
	
	while budget > 0:
		var roll = rng.randi_range(1, totalWeight); 
		var temporalLoaction = {};
		
		for location in list:
			roll -= location["weight"];
			if roll <= 0:
				temporalLoaction = location;	
				break;
				
		
		if temporalLoaction["weight"] <= budget:
			var location = temporalLoaction;
			
			if location["name"] == "Null":
				budget = 0;
			
			budget -= location["weight"];
			_Selection.append(location);
		else:
			break;
	return _Selection;

func Generate_3D_World(world: Node3D) -> void:
	for child in world.get_children():
		if child is Area3D:
			child.queue_free()
	
	# DEPURACION ---------------------------------------------
	if Config.depuration >= 2: print("\n[generator.gd/Generate_3D_World]: ...GENERANDO MUNDO 3D")
	# FIN DEPURACION ----------------------------------------- 
	
	for coordinate2D in map.keys():
		var locationData = map[coordinate2D]
		var locationName = locationData["structure"]
		
		var newLocation = locationScene.instantiate()
		var sprite3D = newLocation.get_node("Sprite3D")
		var collisionBox3D = newLocation.get_node("CollisionShape3D")
		
		if locationsTextures.has(locationName):
			sprite3D.texture = locationsTextures[locationName]
			
		if sprite3D.texture != null:
			var imageWidth = sprite3D.texture.get_width()
			var imageHeight = sprite3D.texture.get_height()
			
			var newPixelSize = Config.cellSize / float(imageWidth)
			sprite3D.pixel_size = newPixelSize # TAMAÑO DE LA IMAGEN
			
			var physicHeight = imageHeight * newPixelSize
			
			var boxShape = BoxShape3D.new()
			boxShape.size = Vector3(Config.cellSize, physicHeight, Config.cellSize)
			
			collisionBox3D.shape = boxShape
		
		# CAMBIO DE COORDENADAS 2D a 3D
		# X 2D = X 3D.
		# Y 2D = Z 3D.
		var position3d = Vector3(
			coordinate2D.x * Config.cellSize, 
			0, # Y 3D = 0 (Suelo)
			coordinate2D.y * Config.cellSize
		)
		
		newLocation.position = position3d
		
		# Si la imagen mide 128px de height y el pixel_size es 0.01 se sube a la mitad
		newLocation.position.y += (sprite3D.texture.get_height() * sprite3D.pixel_size) / 2.0
		
		world.add_child(newLocation)
		
	# DEPURACION ---------------------------------------------
	if Config.depuration >= 1: 
		print("\n[generator.gd/Generate_3D_World]: --- REPORTE DEL MUNDO 3D ---")
		print("- Nodos 3D instanciados: ", map.size())
		print("- Tamaño físico del mundo: ", mapWidth * Config.cellSize, "m x ", mapDepth * Config.cellSize, "m")
		
		print("--------------------------------------------------")
	# FIN DEPURACION -----------------------------------------
