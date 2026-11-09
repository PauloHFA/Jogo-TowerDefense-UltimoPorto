extends RefCounted

const MISSION_TITLES_EN: Array[String] = [
	"First Tide",
	"Wooden Walls",
	"Tar and Fire",
	"Gray Skies",
	"The Bellringer",
	"Stone upon Stone",
	"Barnacles on Rock",
	"Double Tide",
	"Father's Cannon",
	"Barnacle Golem",
	"Iron Rails",
	"Demolition Octopus",
	"Shell upon Shell",
	"Voice in the Bell",
	"Anchor Octopus",
	"Platforms",
	"Storm",
	"Repairs at Sea",
	"The Parliament",
	"Shell Leviathan",
	"Tide Crystal",
	"Mirrors",
	"High Tide",
	"The Choice",
	"The Heart of the Tide",
]

const CHAPTER_TITLES_EN: Array[String] = [
	"Wood and Hope",
	"Stone upon Stone",
	"Iron and Rust",
	"Steel at Sea",
	"The Heart of the Tide",
]

const TOWER_NAMES_EN: Dictionary = {
	"balista": "Ballista",
	"farol_aa": "Anti-Air Beacon",
	"muralha": "Wall",
	"piche": "Tar Boiler",
	"canhao": "Cannon",
	"bobina": "Coil",
	"morteiro": "Mortar",
	"reparo": "Repair Tower",
	"prisma": "Prism Beacon",
}

const MATERIAL_NAMES_EN: Dictionary = {
	"madeira": "Wood",
	"pedra": "Stone",
	"ferro": "Iron",
	"aco": "Steel",
	"cristal_mare": "Tide Crystal",
}

const ENEMY_NAMES_EN: Dictionary = {
	"caranguejinho": "Little Crab",
	"casco_soldado": "Shell Soldier",
	"arraia_vela": "Sail Ray",
	"caranguejo_sineiro": "Bellringer Crab",
	"craca_bomba": "Bomb Barnacle",
	"golem_craca": "Barnacle Golem",
	"polvo_sapador": "Demolition Octopus",
	"fantasma_frota": "Ghost Fleet",
	"polvo_ancora": "Anchor Octopus",
	"medusa_lampiao": "Lantern Jelly",
	"leviata_casco": "Shell Leviathan",
	"coracao_mare": "Admiral Vorraz and the Heart",
}

const CHAPTER_STORIES_EN: Dictionary = {
	1:
	(
		"The Forty-Year Tide came five years early. Teo inherits her father's workshop "
		+ "and learns that a bell commands the Shells."
	),
	2: "Black Coral spreads through the city's works. Anselmo's note warns: do not use Crystal.",
	3: "The city was built from the Forgotten Fleet. Admiral Vorraz speaks through the bell.",
	4: "Bento reveals that he, Anselmo, and Vorraz sealed the Heart. The seal is cracking.",
	5: "Tide Crystal amplifies the Heart. Teo must choose Porto Sentinela's future.",
}

const MISSION_BEATS_EN: Array[String] = [
	"Teo builds her first defenses with boards and nails.",
	"The Captain demands proof that the workshop is useful.",
	"They learn fire hurts the Shells, but wood burns too.",
	"Nina spots flyers while Cabo Pipoca causes a commotion.",
	"A bell calls the Shells; breaking it throws them off rhythm.",
	"Bento teaches the crew to work stone.",
	"Dr. Ramiro reveals Coral growing through the stonework.",
	"The Guard loses a patrol; Lúcia opens up to Teo.",
	"Teo finds the cannon plans and her father's warning: no Crystal.",
	"The Golem guards a ship's diary.",
	"The city industrializes its defenses.",
	"Enemies learn to target the engineering crews.",
	"The shipyard is built from sunken vessels.",
	"The Admiral speaks through the bell for the first time.",
	"Ramiro takes a page from the Book of Plans.",
	"The defenses move out to sea.",
	"Nina and Cabo Pipoca save an outpost.",
	"Bento admits he served as a sapper with Anselmo.",
	"The Admiral proposes a truce and reveals the truth.",
	"The Heart's seal cracks.",
	"Crystal tempts Teo and makes the Shells grow stronger.",
	"Ramiro returns, perhaps remorseful.",
	"The whole city comes together.",
	"Teo decides what to do with the Heart.",
	"The final battle decides Porto Sentinela's fate.",
]

const MISSION_FEATURES_EN: Array[String] = [
	"Tutorial: Ballista and Crab",
	"Wall and Shell Soldier",
	"Tar Boiler; fire and flammable wood",
	"Lantern Ray, an airborne enemy",
	"Boss: Bellringer Crab",
	"Stone material",
	"Bomb Barnacle",
	"Two entrances (sea and land)",
	"Cannon",
	"Boss: Barnacle Golem",
	"Iron material and Coil",
	"Demolition Octopus disables towers",
	"Ghost Fleet",
	"Signal storm",
	"Boss: Anchor Octopus",
	"Steel material and Mortar",
	"Weather alters range and movement speed",
	"Repair Tower",
	"Endurance mission with dialogue",
	"Boss: Leviathan",
	"Tide Crystal and Prism Beacon",
	"Lantern Jelly and prism puzzle",
	"Endurance with giant waves",
	"Choose the final path",
	"Three variants of the final boss",
]

const DIARY_TITLES_EN: Array[String] = [
	"The Bow Bell",
	"Anselmo's Letter",
	"Ballast Stone",
	"The First Coral",
	"Sappers",
	"Hot Iron",
	"Sea Fever",
	"The Decision",
	"The Seal",
	"The Price",
	"Anselmo's Promise",
	"The Last Letter",
]

const OBJECTIVES_EN: Array[String] = [
	"Learn to prioritize the nearest enemy.",
	"Hold the line with a Wall.",
	"Use fire against barnacle armor.",
	"Protect the skies with the Anti-Air Beacon.",
	"Defeat the Bellringer before it rallies the swarm.",
	"Stone is more durable against direct attacks.",
	"Explosives punish clustered barnacles.",
	"Defend both routes with overlapping coverage.",
	"Group enemies to maximize Cannon damage.",
	"Break the Golem's shell with explosives.",
	"Chain lightning punishes clustered enemies.",
	"Protect towers from demolition pulses.",
	"Combine anti-air coverage with area damage.",
	"Reinforce positions before the signal storm.",
	"Stop the Anchor Octopus with explosive damage.",
	"Mortars cover long distances.",
	"The storm alternates range and movement speed.",
	"Repair damaged structures during battle.",
	"The truce pauses the third wave.",
	"Weaken the Leviathan before it reaches the docks.",
	"Crystal deals extra damage to Heart-touched enemies.",
	"Use the Beacon against Lantern Jellies.",
	"Survive the massive waves without losing the docks.",
	"Choose your strategy before the final battle.",
	"Adapt your defenses to Teo's choice.",
]


static func mission_title(mission_id: int, english: bool, fallback: String) -> String:
	if not english:
		return fallback
	return MISSION_TITLES_EN[clampi(mission_id - 1, 0, MISSION_TITLES_EN.size() - 1)]


static func chapter_title(chapter: int, english: bool, fallback: String) -> String:
	if not english:
		return fallback
	return CHAPTER_TITLES_EN[clampi(chapter - 1, 0, CHAPTER_TITLES_EN.size() - 1)]


static func tower_name(tower_id: String, english: bool, fallback: String) -> String:
	return String(TOWER_NAMES_EN.get(tower_id, fallback)) if english else fallback


static func material_name(material_id: String, english: bool, fallback: String) -> String:
	return String(MATERIAL_NAMES_EN.get(material_id, fallback)) if english else fallback


static func enemy_name(enemy_id: String, english: bool, fallback: String) -> String:
	return String(ENEMY_NAMES_EN.get(enemy_id, fallback)) if english else fallback


static func objective(mission_id: int, english: bool, fallback: String) -> String:
	if not english:
		return fallback
	return OBJECTIVES_EN[clampi(mission_id - 1, 0, OBJECTIVES_EN.size() - 1)]


static func mission_beat(mission_id: int, english: bool, fallback: String) -> String:
	if not english:
		return fallback
	return MISSION_BEATS_EN[clampi(mission_id - 1, 0, MISSION_BEATS_EN.size() - 1)]


static func mission_feature(mission_id: int, english: bool, fallback: String) -> String:
	if not english:
		return fallback
	return MISSION_FEATURES_EN[clampi(mission_id - 1, 0, MISSION_FEATURES_EN.size() - 1)]


static func diary_title(diary_id: int, english: bool, fallback: String) -> String:
	if not english:
		return fallback
	return DIARY_TITLES_EN[clampi(diary_id - 1, 0, DIARY_TITLES_EN.size() - 1)]


static func board_message(message: String, english: bool) -> String:
	if not english:
		return message
	var messages: Dictionary = {
		"Modo de construção cancelado.": "Build mode canceled.",
		"Construção cancelada.": "Build canceled.",
		"Onda repelida. Reforce as defesas antes da próxima.":
		"Wave repelled. Reinforce before the next one.",
		"Uma muralha foi destruída por um Casco.": "A Shell destroyed one of your Walls.",
		"O sino silenciou. Os Cascos perderam o ritmo!":
		"The bell is silent. The Shells have lost their rhythm!",
		"Tutorial · etapa 1/3: selecione Construir e coloque uma Balista em terreno livre.":
		"Tutorial · step 1/3: select Build and place a Ballista on open ground.",
		"Tutorial · etapa 2/3: inicie a primeira onda e observe os alvos.":
		"Tutorial · step 2/3: start the first wave and watch the targets.",
		"Tutorial · etapa 2/3: acompanhe os alvos e o alcance das torres.":
		"Tutorial · step 2/3: watch enemy targets and your towers' range.",
		"Tutorial concluído! Agora experimente combinar suas defesas.":
		"Tutorial complete! Now try combining your defenses.",
		"Esta construção já alcançou o nível máximo.":
		"This structure is already at maximum level.",
		"Não é possível bloquear o caminho dos Cascos.": "You cannot block the Shells' route.",
		"Este terreno já está ocupado.": "This tile is already occupied.",
		"Polvo-Sapador desativou uma construção por alguns segundos!":
		"The Demolition Octopus disabled a structure!",
	}
	if messages.has(message):
		return String(messages[message])
	return message
