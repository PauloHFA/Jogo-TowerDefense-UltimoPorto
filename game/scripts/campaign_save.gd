extends RefCounted


static func read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"exists": false, "data": {}, "error": ""}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {
			"exists": true,
			"data": {},
			"error":
			(
				"Não foi possível ler o progresso salvo: %s"
				% error_string(FileAccess.get_open_error())
			),
		}
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	file.close()
	if parse_error != OK:
		return {
			"exists": true,
			"data": {},
			"error":
			(
				"Progresso inválido na linha %d: %s"
				% [json.get_error_line(), json.get_error_message()]
			),
		}
	if not json.data is Dictionary:
		return {
			"exists": true,
			"data": {},
			"error": "O arquivo de progresso não contém um objeto; a campanha iniciará do começo.",
		}
	return {"exists": true, "data": json.data, "error": ""}


static func valid_integer_list(value: Variant, minimum: int, maximum: int) -> Array[int]:
	var result: Array[int] = []
	if not value is Array:
		return result
	for item in value:
		if (
			item is int
			and int(item) >= minimum
			and int(item) <= maximum
			and not result.has(int(item))
		):
			result.append(int(item))
	return result


static func write(path: String, data: Dictionary) -> String:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "Não foi possível salvar o progresso: %s" % error_string(FileAccess.get_open_error())
	var write_succeeded: bool = file.store_string(JSON.stringify(data, "\t"))
	var write_error: Error = file.get_error()
	file.close()
	if write_succeeded:
		return ""
	if write_error == OK:
		write_error = ERR_FILE_CANT_WRITE
	return "Falha ao gravar progresso: %s" % error_string(write_error)
