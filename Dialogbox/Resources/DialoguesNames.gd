@tool
class_name DialoguesNames extends Resource

enum DialogueNames {
	NO, ## No names.
	MONOLOGUE, ## Single speaker for each text line.
	DIALOGUE ## Two and more speakers for text lines.
}

@export var id: int

## If [code]not DialogueNames.NO[/code], you'll see speaker's name.
@export var dialogue_type: DialogueNames:
	set(value):
		dialogue_type = value
		match value:
			DialogueNames.NO: names.clear()
			DialogueNames.MONOLOGUE: names.resize(1)

## If [member dialogue_type] is [code]not DialogueNames.NO[/code] and setted for current [member id] and frame, shows speaker's name. More in [enum DialogueNames].
@export var names: Array[String]:
	set(value): if dialogue_type != DialogueNames.NO:
		names = value
		if dialogue_type == DialogueNames.MONOLOGUE: names.resize(1)
