extends RefCounted

const Campaign = preload("res://scripts/campaign_data.gd")
const Localization = preload("res://scripts/localization.gd")


static func refresh(
	picker: OptionButton, mission_id: int, selected_tower_id: String, english: bool, board: Variant
) -> String:
	picker.clear()
	for tower in Campaign.available_towers(mission_id):
		var item_index := picker.item_count
		(
			picker
			. add_item(
				(
					"%s · %d"
					% [
						Localization.tower_name(
							String(tower["id"]), english, String(tower["name"])
						),
						int(tower["cost"]),
					]
				)
			)
		)
		picker.set_item_metadata(item_index, tower["id"])
	var selected_index := 0
	for index in range(picker.item_count):
		if String(picker.get_item_metadata(index)) == selected_tower_id:
			selected_index = index
			break
	picker.select(selected_index)
	selected_tower_id = String(picker.get_item_metadata(selected_index))
	board.select_tower(selected_tower_id)
	return selected_tower_id
