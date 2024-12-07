@tool
class_name DialoguesVoices extends Resource

enum DialogueVoices {
	NO, ## No voice lines.
	SINGLE, ## Single voice line for each text line.[br]Recommendation: loop your [AudioStream] file.
	EACH_LINE ## Several voice lines for each text line.[br]Recommendation: don't loop your [AudioStream] file.
}

@export var id: int

## If [code]not DialogueVoices.NO[/code], you'll hear voice of speaker if setted in [member voices].
@export var use: DialogueVoices = DialogueVoices.NO:
	set(value):
		use = value
		match value:
			DialogueVoices.NO: voices.clear()
			DialogueVoices.SINGLE: voices.resize(1)

## If [member use] is [code]not DialogueVoices.NO[/code] and setted for current [member id] and frame, starts the voice of the speaker. More in [enum DialogueVoices].
@export var voices: Array[AudioStream]:
	set(value): if use != DialogueVoices.NO:
		voices = value
		if use == DialogueVoices.SINGLE: voices.resize(1)
