extends RefCounted

const CHAPTER_STORIES: Dictionary = {
	1:
	(
		"A Maré dos Quarenta chegou cinco anos antes. Teo assume a oficina do pai "
		+ "e descobre que um sino rege os Cascos."
	),
	2: "O Coral Negro cresce nas obras da cidade. Uma nota de Anselmo avisa: não use Cristal.",
	3:
	(
		"A cidade foi construída com os restos da Frota Esquecida. "
		+ "O Almirante Vorraz fala pelo sino."
	),
	4: "Bento revela que ele, Anselmo e Vorraz selaram o Coração. O selo está rachando.",
	5: "O Cristal-Maré amplifica o Coração. Teo precisa escolher o futuro de Porto Sentinela.",
}

const ENDING_STORIES: Dictionary = {
	"selar":
	(
		"MARÉ CALMA\nO Cristal-Maré é sacrificado e o Coração volta a dormir. "
		+ "Porto Sentinela recomeça com madeira, pedra, ferro e aço. "
		+ "Teo reabre a oficina: Albuquerque e Filha."
	),
	"domar":
	(
		"MARÉ DOMADA\nA cidade torna-se uma fortaleza luminosa. "
		+ "O Almirante sorri: «Quarenta anos, Teodora.» Nina, já adulta, olha para o mar."
	),
	"dialogar":
	(
		"PORTO ABERTO\nCom os doze diários, Teo revela a verdade. "
		+ "A cidade devolve ao mar o que tomou, honra a Frota e estabiliza o Coração. "
		+ "Vorraz finalmente descansa."
	),
}

const ENDING_STORIES_EN: Dictionary = {
	"selar":
	(
		"CALM TIDE\nTide Crystal is sacrificed and the Heart falls silent. "
		+ "Porto Sentinela rebuilds with wood, stone, iron, and steel. "
		+ "Teo reopens the workshop: Albuquerque & Daughter."
	),
	"domar":
	(
		"TAMED TIDE\nThe city becomes a fortress of light. "
		+ "The Admiral smiles: “Forty years, Teodora.” Nina, now grown, watches the sea."
	),
	"dialogar":
	(
		"OPEN PORT\nWith all twelve journals, Teo tells the truth. "
		+ "The city returns what it took from the sea, honors the Fleet, and steadies the Heart. "
		+ "Vorraz can finally rest."
	),
}

const POST_MISSION_EVENTS: Dictionary = {
	5: "O sino continua tocando. Os Cascos param e olham para o mar: alguém está regendo a frota.",
	9:
	(
		"A planta do canhão traz uma nota de Anselmo: "
		+ "«Se o mar voltar, constrói firme e simples. E não use Cristal.»"
	),
	10: "O diário de bordo revela que Vorraz mandou afundar a própria frota.",
	14: "A voz no sino chama Teo de filha de Anselmo e fala de uma culpa ainda não revelada.",
	15: "Uma página do Livro de Plantas desapareceu. Ramiro fugiu com a planta do Cristal.",
	20: "O selo do Coração rachou. A cidade inteira está sobre os restos da Frota Esquecida.",
	21: "Ramiro confessa: cada torre de Cristal ouve o Coração, e o Coração ouve de volta.",
	23: "Os diários contam a amizade entre Anselmo e Vorraz. Agora Teo pode escolher Dialogar.",
}

const POST_MISSION_EVENTS_EN: Dictionary = {
	5:
	"The bell keeps ringing. The Shells stop and look out to sea: someone is commanding the fleet.",
	9:
	"Anselmo's note on the cannon plans reads: “Build strong and simple. And do not use Crystal.”",
	10: "The ship's diary reveals that Vorraz ordered his own fleet sunk.",
	14: "The voice in the bell calls Teo Anselmo's daughter and hints at a hidden guilt.",
	15: "A page from the Book of Plans is missing. Ramiro escaped with the Crystal plans.",
	20: "The Heart's seal cracks. The entire city stands on the remains of the Forgotten Fleet.",
	21: "Ramiro confesses: every Crystal tower hears the Heart, and the Heart hears back.",
	23: "The journals tell of Anselmo and Vorraz's friendship. " + "Now Teo can choose to talk.",
}


static func chapter_story(chapter: int, english: bool) -> String:
	if english:
		return String(
			(
				{
					1:
					(
						"The Forty-Year Tide came five years early. "
						+ "Teo inherits her father's workshop and learns that a bell commands the Shells."
					),
					2:
					"Black Coral spreads through the city's works. Anselmo's note warns: do not use Crystal.",
					3:
					"The city was built from the Forgotten Fleet. Admiral Vorraz speaks through the bell.",
					4:
					"Bento reveals that he, Anselmo, and Vorraz sealed the Heart. The seal is cracking.",
					5:
					"Tide Crystal amplifies the Heart. Teo must choose Porto Sentinela's future.",
				}
				. get(chapter, "")
			)
		)
	return String(CHAPTER_STORIES.get(chapter, ""))


static func ending_story(choice: String, english: bool) -> String:
	var stories: Dictionary = ENDING_STORIES_EN if english else ENDING_STORIES
	return String(stories.get(choice, stories["selar"]))


static func post_mission(mission_id: int, english: bool, banked_wood: int) -> String:
	var events: Dictionary = POST_MISSION_EVENTS_EN if english else POST_MISSION_EVENTS
	var default_text := (
		"Porto Sentinela's story moves forward."
		if english
		else "A história de Porto Sentinela avança."
	)
	var wood_text := "Campaign wood: %d." if english else "Madeira para a campanha: %d."
	return "%s\n\n%s" % [String(events.get(mission_id, default_text)), wood_text % banked_wood]
