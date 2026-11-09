extends RefCounted

const MATERIALS: Array[Dictionary] = [
	{
		"id": "madeira",
		"name": "Madeira",
		"chapter": 1,
		"cost": 1.0,
		"power": 1.0,
		"range": 1.0,
		"durability": 1.0,
		"armor_piercing": 0.0,
		"fire_rate": 1.0,
	},
	{
		"id": "pedra",
		"name": "Pedra",
		"chapter": 2,
		"cost": 1.2,
		"power": 1.25,
		"range": 0.9,
		"durability": 1.6,
		"armor_piercing": 0.0,
		"fire_rate": 0.9,
	},
	{
		"id": "ferro",
		"name": "Ferro",
		"chapter": 3,
		"cost": 1.45,
		"power": 1.5,
		"range": 1.0,
		"durability": 1.2,
		"armor_piercing": 0.2,
		"fire_rate": 1.0,
	},
	{
		"id": "aco",
		"name": "Aço",
		"chapter": 4,
		"cost": 1.75,
		"power": 1.75,
		"range": 1.12,
		"durability": 1.05,
		"armor_piercing": 0.12,
		"fire_rate": 1.12,
	},
	{
		"id": "cristal_mare",
		"name": "Cristal-Maré",
		"chapter": 5,
		"cost": 2.15,
		"power": 2.4,
		"range": 1.18,
		"durability": 0.82,
		"armor_piercing": 0.1,
		"fire_rate": 1.05,
	},
]

const TOWERS: Array[Dictionary] = [
	{
		"id": "balista",
		"name": "Balista",
		"chapter": 1,
		"unlock_mission": 1,
		"cost": 40,
		"damage": 25.0,
		"range": 2.35,
		"cooldown": 0.68,
		"role": "single",
		"damage_type": "physical",
		"description": "Disparo preciso contra um Casco.",
	},
	{
		"id": "farol_aa",
		"name": "Farol Antiaéreo",
		"chapter": 1,
		"unlock_mission": 4,
		"cost": 68,
		"damage": 23.0,
		"range": 3.2,
		"cooldown": 0.58,
		"role": "antiair",
		"damage_type": "electric",
		"description": "Prioriza inimigos voadores; ganha alcance contra eles.",
	},
	{
		"id": "muralha",
		"name": "Muralha",
		"chapter": 1,
		"unlock_mission": 2,
		"cost": 32,
		"damage": 0.0,
		"range": 0.0,
		"cooldown": 0.0,
		"role": "wall",
		"description": "Absorve dano de um Casco-Soldado adjacente.",
	},
	{
		"id": "piche",
		"name": "Caldeira de Piche",
		"chapter": 1,
		"unlock_mission": 3,
		"cost": 55,
		"damage": 13.0,
		"range": 1.8,
		"cooldown": 1.05,
		"role": "burn",
		"damage_type": "fire",
		"description": "Queima inimigos próximos; madeira queima com facilidade.",
	},
	{
		"id": "canhao",
		"name": "Canhão",
		"chapter": 2,
		"unlock_mission": 9,
		"cost": 90,
		"damage": 35.0,
		"range": 3.0,
		"cooldown": 1.35,
		"role": "splash",
		"damage_type": "explosive",
		"description": "Dano em área contra grupos.",
	},
	{
		"id": "bobina",
		"name": "Bobina",
		"chapter": 3,
		"unlock_mission": 11,
		"cost": 105,
		"damage": 20.0,
		"range": 2.65,
		"cooldown": 0.92,
		"role": "chain",
		"damage_type": "electric",
		"description": "Corrente elétrica salta entre Cascos.",
	},
	{
		"id": "morteiro",
		"name": "Morteiro",
		"chapter": 4,
		"unlock_mission": 16,
		"cost": 145,
		"damage": 66.0,
		"range": 3.7,
		"cooldown": 1.9,
		"role": "splash",
		"damage_type": "explosive",
		"description": "Projétil pesado; longo alcance e recarga lenta.",
	},
	{
		"id": "reparo",
		"name": "Torre de Reparo",
		"chapter": 4,
		"unlock_mission": 18,
		"cost": 125,
		"damage": 0.0,
		"range": 2.4,
		"cooldown": 3.0,
		"role": "repair",
		"description": "Restaura a integridade de uma construção próxima.",
	},
	{
		"id": "prisma",
		"name": "Farol de Prisma",
		"chapter": 5,
		"unlock_mission": 21,
		"cost": 180,
		"damage": 62.0,
		"range": 3.1,
		"cooldown": 0.83,
		"role": "prism",
		"damage_type": "crystal",
		"description": "Muito poderoso; acelera a maré de Cristal.",
	},
]

const ENEMIES: Dictionary = {
	"caranguejinho":
	{
		"name": "Caranguejinho",
		"chapter": 1,
		"health": 64.0,
		"speed": 61.0,
		"reward": 7,
		"armor": 0.0,
		"flying": false,
		"ability": "none",
		"resistances": {"physical": 0.9, "explosive": 0.9},
		"weaknesses": {"fire": 1.25, "electric": 1.1},
	},
	"casco_soldado":
	{
		"name": "Casco-Soldado",
		"chapter": 1,
		"health": 145.0,
		"speed": 38.0,
		"reward": 12,
		"armor": 0.16,
		"flying": false,
		"ability": "none",
		"resistances": {"physical": 0.78},
		"weaknesses": {"fire": 1.25, "explosive": 1.1},
	},
	"arraia_vela":
	{
		"name": "Arraia-Vela",
		"chapter": 1,
		"health": 80.0,
		"speed": 75.0,
		"reward": 10,
		"armor": 0.0,
		"flying": true,
		"ability": "none",
		"resistances": {"physical": 0.85},
		"weaknesses": {"electric": 1.3, "explosive": 1.15},
	},
	"caranguejo_sineiro":
	{
		"name": "Caranguejo Sineiro",
		"chapter": 1,
		"health": 460.0,
		"speed": 29.0,
		"reward": 70,
		"armor": 0.12,
		"flying": false,
		"ability": "signal",
		"resistances": {"physical": 0.8},
		"weaknesses": {"electric": 1.2, "explosive": 1.15},
	},
	"craca_bomba":
	{
		"name": "Craca-Bomba",
		"chapter": 2,
		"health": 116.0,
		"speed": 54.0,
		"reward": 13,
		"armor": 0.06,
		"flying": false,
		"ability": "burst",
		"resistances": {"fire": 0.85},
		"weaknesses": {"electric": 1.2, "physical": 1.1},
	},
	"golem_craca":
	{
		"name": "Gólem de Craca",
		"chapter": 2,
		"health": 990.0,
		"speed": 23.0,
		"reward": 105,
		"armor": 0.25,
		"flying": false,
		"ability": "siege",
		"resistances": {"physical": 0.7, "fire": 0.85},
		"weaknesses": {"explosive": 1.3, "electric": 1.2},
	},
	"polvo_sapador":
	{
		"name": "Polvo-Sapador",
		"chapter": 3,
		"health": 180.0,
		"speed": 44.0,
		"reward": 20,
		"armor": 0.05,
		"flying": false,
		"ability": "disable",
		"resistances": {"electric": 0.7},
		"weaknesses": {"fire": 1.3, "explosive": 1.15},
	},
	"fantasma_frota":
	{
		"name": "Fantasma da Frota",
		"chapter": 3,
		"health": 210.0,
		"speed": 66.0,
		"reward": 22,
		"armor": 0.08,
		"flying": true,
		"ability": "none",
		"resistances": {"physical": 0.8},
		"weaknesses": {"electric": 1.3, "fire": 1.15},
	},
	"polvo_ancora":
	{
		"name": "Polvo-Âncora",
		"chapter": 3,
		"health": 1420.0,
		"speed": 27.0,
		"reward": 145,
		"armor": 0.28,
		"flying": false,
		"ability": "disable",
		"resistances": {"physical": 0.65, "electric": 0.8},
		"weaknesses": {"explosive": 1.35},
	},
	"medusa_lampiao":
	{
		"name": "Medusa-Lampião",
		"chapter": 5,
		"health": 290.0,
		"speed": 51.0,
		"reward": 32,
		"armor": 0.12,
		"flying": true,
		"ability": "signal",
		"resistances": {"fire": 0.85},
		"weaknesses": {"electric": 1.3, "physical": 1.15},
	},
	"leviata_casco":
	{
		"name": "Leviatã de Casco",
		"chapter": 4,
		"health": 2250.0,
		"speed": 19.0,
		"reward": 190,
		"armor": 0.35,
		"flying": false,
		"ability": "siege",
		"resistances": {"physical": 0.65, "fire": 0.8},
		"weaknesses": {"explosive": 1.3, "crystal": 1.15},
	},
	"coracao_mare":
	{
		"name": "Almirante Vorraz e o Coração",
		"chapter": 5,
		"health": 3450.0,
		"speed": 21.0,
		"reward": 300,
		"armor": 0.3,
		"flying": false,
		"ability": "final",
		"resistances": {"physical": 0.7, "fire": 0.8, "electric": 0.8},
		"weaknesses": {"explosive": 1.2, "crystal": 1.35},
	},
}
const BOSS_IDS: Array[String] = [
	"caranguejo_sineiro",
	"golem_craca",
	"polvo_ancora",
	"leviata_casco",
	"coracao_mare",
]

const DIARIES: Array[Dictionary] = [
	{"id": 1, "chapter": 1, "mission": 1, "title": "O Sino de Proa"},
	{"id": 2, "chapter": 1, "mission": 3, "title": "Carta de Anselmo"},
	{"id": 3, "chapter": 2, "mission": 6, "title": "Pedra de Lastro"},
	{"id": 4, "chapter": 2, "mission": 7, "title": "O Primeiro Coral"},
	{"id": 5, "chapter": 2, "mission": 10, "title": "Sapadores"},
	{"id": 6, "chapter": 3, "mission": 11, "title": "Ferro Quente"},
	{"id": 7, "chapter": 3, "mission": 12, "title": "Febre do Mar"},
	{"id": 8, "chapter": 3, "mission": 15, "title": "A Decisão"},
	{"id": 9, "chapter": 4, "mission": 16, "title": "O Selo"},
	{"id": 10, "chapter": 4, "mission": 18, "title": "O Preço"},
	{"id": 11, "chapter": 5, "mission": 21, "title": "Promessa de Anselmo"},
	{"id": 12, "chapter": 5, "mission": 23, "title": "A Última Carta"},
]

const MISSIONS: Array[Dictionary] = [
	{
		"id": 1,
		"chapter": 1,
		"title": "Primeira Maré",
		"site": "Cais Velho",
		"feature": "Tutorial: Balista e Caranguejinho",
		"beat": "Teo monta as primeiras defesas com tábuas e pregos.",
		"boss": "",
	},
	{
		"id": 2,
		"chapter": 1,
		"title": "Muros de Madeira",
		"site": "Cais Velho",
		"feature": "Muralha e Casco-Soldado",
		"beat": "A Capitã exige provas de que a oficina serve.",
		"boss": "",
	},
	{
		"id": 3,
		"chapter": 1,
		"title": "Fogo no Piche",
		"site": "Cais Velho",
		"feature": "Caldeira de Piche; fogo e madeira inflamável",
		"beat": "Descobrem que fogo fere os Cascos; madeira também queima.",
		"boss": "",
	},
	{
		"id": 4,
		"chapter": 1,
		"title": "Céu Cinzento",
		"site": "Cais Velho",
		"feature": "Arraia-Vela, inimigo aéreo",
		"beat": "Nina avista voadores e Cabo Pipoca causa confusão.",
		"boss": "",
	},
	{
		"id": 5,
		"chapter": 1,
		"title": "O Sineiro",
		"site": "Cais Velho",
		"feature": "Chefe: Caranguejo Sineiro",
		"beat": "Um sino chama os Cascos; quebrá-lo os desorienta.",
		"boss": "caranguejo_sineiro",
	},
	{
		"id": 6,
		"chapter": 2,
		"title": "Pedra sobre Pedra",
		"site": "Pedreira Tomada",
		"feature": "Material Pedra",
		"beat": "Bento ensina a trabalhar a pedra.",
		"boss": "",
	},
	{
		"id": 7,
		"chapter": 2,
		"title": "Craca na Rocha",
		"site": "Pedreira Tomada",
		"feature": "Craca-Bomba",
		"beat": "O Dr. Ramiro mostra o Coral crescendo na obra.",
		"boss": "",
	},
	{
		"id": 8,
		"chapter": 2,
		"title": "Maré Dupla",
		"site": "Pedreira Tomada",
		"feature": "Duas entradas (mar e terra)",
		"beat": "A Guarda perde uma patrulha; Lúcia se abre com Teo.",
		"boss": "",
	},
	{
		"id": 9,
		"chapter": 2,
		"title": "O Canhão do Pai",
		"site": "Pedreira Tomada",
		"feature": "Canhão",
		"beat": "Teo acha a planta e a nota do pai: não use Cristal.",
		"boss": "",
	},
	{
		"id": 10,
		"chapter": 2,
		"title": "Gólem de Craca",
		"site": "Pedreira Tomada",
		"feature": "Chefe: Gólem de Craca",
		"beat": "O gólem guarda um diário de bordo.",
		"boss": "golem_craca",
	},
	{
		"id": 11,
		"chapter": 3,
		"title": "Trilhos de Ferro",
		"site": "Estaleiro Sombrio",
		"feature": "Material Ferro e Bobina",
		"beat": "A cidade industrializa a defesa.",
		"boss": "",
	},
	{
		"id": 12,
		"chapter": 3,
		"title": "Polvo-Sapador",
		"site": "Estaleiro Sombrio",
		"feature": "Polvo-Sapador desativa torres",
		"beat": "Inimigos aprendem a atacar a engenharia.",
		"boss": "",
	},
	{
		"id": 13,
		"chapter": 3,
		"title": "Casco no Casco",
		"site": "Estaleiro Sombrio",
		"feature": "Fantasma da Frota",
		"beat": "O estaleiro é feito de navios afundados.",
		"boss": "",
	},
	{
		"id": 14,
		"chapter": 3,
		"title": "Voz no Sino",
		"site": "Estaleiro Sombrio",
		"feature": "Tempestade de sinais",
		"beat": "O Almirante fala pela primeira vez.",
		"boss": "",
	},
	{
		"id": 15,
		"chapter": 3,
		"title": "Polvo-Âncora",
		"site": "Estaleiro Sombrio",
		"feature": "Chefe: Polvo-Âncora",
		"beat": "Ramiro leva uma página do Livro de Plantas.",
		"boss": "polvo_ancora",
	},
	{
		"id": 16,
		"chapter": 4,
		"title": "Plataformas",
		"site": "Alto-Mar de Cinzas",
		"feature": "Material Aço e Morteiro",
		"beat": "A defesa vai para o mar.",
		"boss": "",
	},
	{
		"id": 17,
		"chapter": 4,
		"title": "Tempestade",
		"site": "Alto-Mar de Cinzas",
		"feature": "Clima altera alcance e velocidade",
		"beat": "Nina e Cabo Pipoca salvam um posto.",
		"boss": "",
	},
	{
		"id": 18,
		"chapter": 4,
		"title": "Reparo no Mar",
		"site": "Alto-Mar de Cinzas",
		"feature": "Torre de Reparo",
		"beat": "Bento conta que foi sapador com Anselmo.",
		"boss": "",
	},
	{
		"id": 19,
		"chapter": 4,
		"title": "O Parlamento",
		"site": "Alto-Mar de Cinzas",
		"feature": "Missão de resistência com diálogo",
		"beat": "O Almirante propõe uma trégua e revela a verdade.",
		"boss": "",
	},
	{
		"id": 20,
		"chapter": 4,
		"title": "Leviatã de Casco",
		"site": "Alto-Mar de Cinzas",
		"feature": "Chefe: Leviatã",
		"beat": "O selo do Coração racha.",
		"boss": "leviata_casco",
	},
	{
		"id": 21,
		"chapter": 5,
		"title": "Cristal-Maré",
		"site": "Coração da Maré",
		"feature": "Cristal-Maré e Farol de Prisma",
		"beat": "O poder tenta Teo; o Cristal faz os Cascos crescerem.",
		"boss": "",
	},
	{
		"id": 22,
		"chapter": 5,
		"title": "Espelhos",
		"site": "Coração da Maré",
		"feature": "Medusa-Lampião e puzzle de prismas",
		"beat": "Ramiro volta, arrependido ou não.",
		"boss": "",
	},
	{
		"id": 23,
		"chapter": 5,
		"title": "Maré Cheia",
		"site": "Coração da Maré",
		"feature": "Resistência com ondas gigantes",
		"beat": "A cidade inteira ajuda.",
		"boss": "",
	},
	{
		"id": 24,
		"chapter": 5,
		"title": "A Escolha",
		"site": "Coração da Maré",
		"feature": "Escolha de caminho final",
		"beat": "Teo decide o que fazer com o Coração.",
		"boss": "",
	},
	{
		"id": 25,
		"chapter": 5,
		"title": "O Coração da Maré",
		"site": "Coração da Maré",
		"feature": "Chefe final em três variantes",
		"beat": "A batalha final define o destino de Porto Sentinela.",
		"boss": "coracao_mare",
	},
]

const CHAPTER_NAMES: Array[String] = [
	"Madeira e Esperança",
	"Pedra sobre Pedra",
	"Ferro e Ferrugem",
	"Aço em Alto-Mar",
	"O Coração da Maré",
]

const MISSION_ENCOUNTERS: Array[Dictionary] = [
	{"pool": ["caranguejinho"], "objective": "Aprenda a priorizar o inimigo mais próximo."},
	{"pool": ["caranguejinho", "casco_soldado"], "objective": "Segure a linha com uma Muralha."},
	{
		"pool": ["casco_soldado", "caranguejinho"],
		"objective": "Use fogo contra a armadura de craca."
	},
	{"pool": ["arraia_vela", "caranguejinho"], "objective": "Proteja o céu com o Farol Antiaéreo."},
	{
		"pool": ["caranguejinho", "casco_soldado"],
		"objective": "Derrube o Sineiro antes que reforce a marcha."
	},
	{
		"pool": ["casco_soldado", "caranguejinho"],
		"objective": "Pedra resiste melhor a ataques diretos."
	},
	{
		"pool": ["craca_bomba", "casco_soldado"],
		"objective": "Explosivos punem aglomerados de cracas."
	},
	{
		"pool": ["arraia_vela", "craca_bomba", "casco_soldado"],
		"objective": "Defenda duas rotas alternando cobertura."
	},
	{
		"pool": ["casco_soldado", "craca_bomba"],
		"objective": "Agrupe inimigos para aproveitar o Canhão."
	},
	{
		"pool": ["craca_bomba", "casco_soldado"],
		"objective": "Quebre a carapaça do Gólem com explosivos."
	},
	{
		"pool": ["fantasma_frota", "polvo_sapador"],
		"objective": "Eletricidade encadeada pune grupos."
	},
	{
		"pool": ["polvo_sapador", "casco_soldado"],
		"objective": "Proteja torres contra o pulso sapador."
	},
	{
		"pool": ["fantasma_frota", "craca_bomba"],
		"objective": "Combine cobertura aérea e dano em área."
	},
	{
		"pool": ["polvo_sapador", "fantasma_frota"],
		"objective": "Reforce posições antes da tempestade de sinais."
	},
	{
		"pool": ["polvo_sapador", "fantasma_frota"],
		"objective": "Interrompa o Polvo-Âncora com dano explosivo."
	},
	{
		"pool": ["fantasma_frota", "polvo_sapador"],
		"objective": "Morteiros cobrem longas distâncias."
	},
	{
		"pool": ["fantasma_frota", "polvo_sapador"],
		"objective": "A tempestade alterna alcance e velocidade."
	},
	{
		"pool": ["polvo_sapador", "fantasma_frota"],
		"objective": "Repare estruturas danificadas durante a luta."
	},
	{
		"pool": ["fantasma_frota", "polvo_sapador"],
		"objective": "A trégua interrompe a terceira onda."
	},
	{
		"pool": ["fantasma_frota", "polvo_sapador"],
		"objective": "Desgaste o Leviatã antes que alcance o cais."
	},
	{
		"pool": ["medusa_lampiao", "fantasma_frota"],
		"objective": "Cristal causa mais dano a alvos do Coração."
	},
	{
		"pool": ["medusa_lampiao", "polvo_sapador"],
		"objective": "Use o Farol contra as Medusas-Lampião."
	},
	{
		"pool": ["medusa_lampiao", "polvo_sapador"],
		"objective": "Sobreviva às ondas gigantes sem perder o cais."
	},
	{
		"pool": ["medusa_lampiao", "fantasma_frota"],
		"objective": "Escolha uma estratégia antes da batalha final."
	},
	{
		"pool": ["medusa_lampiao", "polvo_sapador"],
		"objective": "Adapte as defesas à escolha feita por Teo."
	},
]


static func mission_at(index: int) -> Dictionary:
	return MISSIONS[clampi(index, 0, MISSIONS.size() - 1)]


static func tower_by_id(tower_id: String) -> Dictionary:
	for tower in TOWERS:
		if tower["id"] == tower_id:
			return tower
	return {}


static func material_for_chapter(chapter: int) -> Dictionary:
	return MATERIALS[clampi(chapter - 1, 0, MATERIALS.size() - 1)]


static func material_by_id(material_id: String) -> Dictionary:
	for material in MATERIALS:
		if String(material["id"]) == material_id:
			return material
	return MATERIALS[0]


static func available_towers(mission_id: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for tower in TOWERS:
		if int(tower["unlock_mission"]) <= mission_id:
			result.append(tower)
	return result


static func available_enemies(chapter: int) -> Array[String]:
	var result: Array[String] = []
	for enemy_id in ENEMIES:
		if int(ENEMIES[enemy_id]["chapter"]) <= chapter and not BOSS_IDS.has(String(enemy_id)):
			result.append(enemy_id)
	return result


static func diary_for_mission(mission_id: int) -> Dictionary:
	for diary in DIARIES:
		if int(diary["mission"]) == mission_id:
			return diary
	return {}


static func wave_composition(mission_id: int, wave_index: int) -> Array[Dictionary]:
	var mission := mission_at(mission_id - 1)
	var chapter := int(mission["chapter"])
	var encounter: Dictionary = MISSION_ENCOUNTERS[mission_id - 1]
	var pool: Array = encounter["pool"]
	var count := 5 + chapter * 2 + wave_index * 2 + int((mission_id + wave_index) % 3)
	var composition: Array[Dictionary] = []
	for index in range(count):
		var profile_index := (index + wave_index + mission_id) % pool.size()
		if wave_index == 0:
			profile_index = 0
		elif wave_index >= 3 and pool.size() > 1:
			profile_index = (profile_index + 1) % pool.size()
		var enemy_id: String = pool[profile_index]
		composition.append({"id": enemy_id, "boss": false})

	if wave_index == 4 and not String(mission["boss"]).is_empty():
		composition.append({"id": mission["boss"], "boss": true})
	return composition


static func encounter_for_mission(mission_id: int) -> Dictionary:
	return MISSION_ENCOUNTERS[clampi(mission_id - 1, 0, MISSION_ENCOUNTERS.size() - 1)]
