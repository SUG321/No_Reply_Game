class_name Generator
extends RefCounted

# MAQUINAS Y VARIABLES
static var rng = RandomNumberGenerator.new()
static var ruido = FastNoiseLite.new()

static var dep = 2
static var mapa = {}
static var tamC3D = 4

# DICCIONARIOS
static var locaciones = ObjDictionary.Structures
static var objetos = ObjDictionary.Items
static var limites = ObjDictionary.Dificults
static var locacionesTex = ObjDictionary.StructuresTexts


static func Generate(Seed: String, world: Node3D) -> Dictionary:
	var _World = {};
	var presupuesto = limites[2]["peso"];
	
	var _Seed = Seed.hash()
	rng.seed = _Seed
	ruido.seed = _Seed
	ruido.noise_type = FastNoiseLite.TYPE_PERLIN
	ruido.frequency = 0.08
	
	Generate_Map(30, 20)
	Generate3D(world)
	
	_World = Generate_World(presupuesto);
	return _World

static func Generate_Map(ancho: int, alto: int):
	mapa.clear()
	if dep>= 2: print("\n...INIT GEN MAPA")
	
	for y in range(alto):
		var fila = ""
		for x in range(ancho):
			var valor = ruido.get_noise_2d(x, y)
			var prespCelda = 0
			var icono = ""
			
			if valor > 0.3:
				prespCelda = 80
				icono = "██"
			elif valor > 0.0:
				prespCelda = 30
				icono += "▒▒"
			else:
				prespCelda = 10
				icono += ".."
			
			fila += icono
			
			var genLocs = Generate_Item(prespCelda, locaciones)
			if genLocs.size() > 0:
				var prinLoc = genLocs[0]
				if prinLoc["nombre"] != "Nada":
					var genObjs = Generate_Item(prinLoc["loot"], objetos)
					var listLoot = []
					for obj in genObjs:
						listLoot.append(obj["nombre"])
					mapa[Vector2(x, y)] = {
						"estructura": prinLoc["nombre"],
						"loot": listLoot
					}
		print(fila)

	if dep >= 1: print("\nGENERACION MAPA TERMINADA -----------------");
	if dep >= 2: print("\nEl mundo tiene ", mapa.size(), " locaciones con loot")
	
	if dep >= 3:
		var test_coord = Vector2(10, 10)
		if mapa.has(test_coord):
			print("\nEn la coordenada ", test_coord, " hay: ", mapa[test_coord]["estructura"])
			print("Contiene este loot: ", mapa[test_coord]["loot"])
		else:
			print("\nLa coordenada ", test_coord, " es un terreno vacío.")
	

static func Generate_World(presupuesto) -> Dictionary:
	var _Final = {};
	var Locaciones_Temp = Generate_Item(presupuesto, locaciones);
	if dep >= 1: print("\nGENERACION LOCACIONES TERMINADA -----------------");
	
	for loc in Locaciones_Temp:
		var Objetos_Temp = Generate_Item(loc["loot"], objetos);
		if dep >= 1: print("GENERACION LOOT " + loc["nombre"] + " TERMINADA -----------------");
		
		_Final[loc["nombre"]] = [];
		
		for obj in Objetos_Temp:
			_Final[loc["nombre"]].append(obj["nombre"]);
	
	return _Final;

static func Generate_Item(presupuesto: int, lista: Array) -> Array:
	var pesoTotal = 0;
	var _Seleccion = [];
	
	for i in range(lista.size()):
		pesoTotal += lista[i]["peso"];
	
	while presupuesto > 0:
		var tirada = rng.randi_range(1, pesoTotal); 
		var locacionTemporal = {};
		
		for loc in lista:
			tirada -= loc["peso"];
			if tirada <= 0:
				locacionTemporal = loc;	
				break;
				
		
		if locacionTemporal["peso"] <= presupuesto:
			var loc = locacionTemporal;
			
			if loc["nombre"] == "Nada":
				presupuesto = 0;
			
			presupuesto -= loc["peso"];
			_Seleccion.append(loc);
		else:
			break;
	return _Seleccion;

static func Generate3D(world: Node3D) -> void:
	for child in world.get_children():
		if child is Sprite3D:
			child.queue_free()
	
	if dep >= 2: print("\n...LEVANTANDO EL MUNDO 3D")
	
	for coordenada2D in mapa.keys():
		var locDatos = mapa[coordenada2D]
		var locNombre = locDatos["estructura"]
		var newSprite3D = Sprite3D.new()
		
		if locacionesTex.has(locNombre):
			newSprite3D.texture = locacionesTex[locNombre]
		
		# BILLBOARD
		newSprite3D.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		
		# CAMBIO DE COORDENADAS 2D a 3D
		# X 2D = X 3D.
		# Y 2D = Z 3D.
		var posicion_3d = Vector3(
			coordenada2D.x * tamC3D, 
			0, # Y 3D = 0 (Suelo)
			coordenada2D.y * tamC3D
		)
		
		newSprite3D.position = posicion_3d
		
		# Si la imagen mide 128px de alto y el pixel_size es 0.01 se sube a la mitad
		newSprite3D.position.y += (newSprite3D.texture.get_height() * newSprite3D.pixel_size) / 2.0
		
		world.add_child.call_deferred(newSprite3D)
		
	if dep >= 1: print("GENERACION DE MAPA 3D TERMINADA (" , mapa.size(), " estructuras)", " ----------------- ")
