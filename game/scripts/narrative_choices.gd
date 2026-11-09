extends RefCounted

signal choice_selected(choice: String)
signal trust_selected(trust: bool)
signal dismissed

const ModalDialogScript = preload("res://scripts/modal_dialog.gd")


func show_ramiro(parent: Control, english: bool, large_text: bool) -> Control:
	var actions: Array[Dictionary] = [
		{
			"text": "Trust Ramiro" if english else "Confiar em Ramiro",
			"action": Callable(self, "_emit_trust").bind(true),
		},
		{
			"text": "Refuse his help" if english else "Recusar ajuda",
			"action": Callable(self, "_emit_trust").bind(false),
		},
	]
	var body := (
		(
			"Ramiro offers to help defend the Heart. "
			+ "Teo can trust him or demand that he stay away."
		)
		if english
		else (
			"Ramiro oferece ajudar com as defesas do Coração. "
			+ "Teo pode confiar nele ou exigir que se afaste."
		)
	)
	return _dialog(
		parent, "Ramiro returns" if english else "Ramiro voltou", body, actions, large_text
	)


func show_truce(parent: Control, english: bool, large_text: bool) -> Control:
	var body := (
		(
			"ADMIRAL: “Forty years ago, we sank the fleet to seal the Heart.”\n\n"
			+ "TEO: “That means letting the city die.”\n\n"
			+ "Do you trust the Admiral's account or reject the truce?"
		)
		if english
		else (
			"ALMIRANTE: «Há quarenta anos, afundamos a frota para selar o Coração.»\n\n"
			+ "TEO: «Isso quer dizer deixar a cidade morrer.»\n\n"
			+ "Você confia na versão do Almirante ou rejeita a trégua?"
		)
	)
	var actions: Array[Dictionary] = [
		{
			"text": "Hear Vorraz out" if english else "Ouvir Vorraz",
			"action": Callable(self, "_emit_trust").bind(true),
		},
		{
			"text": "Reject the truce" if english else "Rejeitar a trégua",
			"action": Callable(self, "_emit_trust").bind(false),
		},
	]
	return _dialog(
		parent,
		"The Parliament · Truce" if english else "O Parlamento · trégua",
		body,
		actions,
		large_text
	)


func show_endings(
	parent: Control, english: bool, journal_count: int, journals_complete: bool, large_text: bool
) -> Control:
	var body := ""
	if english:
		body = (
			"TEO: “My father chose alone. I won't.”\n\nChoose the Heart's fate. "
			+ "“Talk” requires all twelve ship journals (%d/12 found)." % journal_count
		)
	else:
		body = (
			"TEO: «Meu pai escolheu sozinho. Eu não vou.»\n\nEscolha o destino do Coração. "
			+ "«Dialogar» exige os doze diários de bordo (%d/12 encontrados)." % journal_count
		)
	var actions: Array[Dictionary] = [
		{
			"text": "Seal" if english else "Selar",
			"action": Callable(self, "_emit_choice").bind("selar"),
		},
		{
			"text": "Tame" if english else "Domar",
			"action": Callable(self, "_emit_choice").bind("domar"),
		},
		{
			"text": "Talk · requires 12 journals" if english else "Dialogar · requer 12 diários",
			"action": Callable(self, "_emit_choice").bind("dialogar"),
			"disabled": not journals_complete,
		},
		{
			"text": "Back" if english else "Voltar",
			"action": Callable(self, "_emit_dismiss"),
		},
	]
	return _dialog(parent, "The Choice" if english else "A Escolha", body, actions, large_text)


func _dialog(
	parent: Control, title: String, body: String, actions: Array[Dictionary], large_text: bool
) -> Control:
	var dialog: Variant = ModalDialogScript.new()
	return dialog.show(parent, title, body, actions, large_text)


func _emit_choice(choice: String) -> void:
	choice_selected.emit(choice)


func _emit_trust(trust: bool) -> void:
	trust_selected.emit(trust)


func _emit_dismiss() -> void:
	dismissed.emit()
