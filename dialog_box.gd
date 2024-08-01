@tool
extends Control #EditorPlugin

## Custom class for easy dialogues.
## 
## DialogBox is custom class for fast creating game dialogues.[br]
## For starting of speaking you'll need to set some variables, so here's the template:
## [codeblock]
## emit_signal("resetting", DialogBox.DialogueNames.DIALOGUE, true, DialogBox.DialogueVoices.SINGLE)
## dialogue_lines = ["Hello!", "How are you?", "Pretty fine, thanks!"] as Array[String]
## dialogue_names = ["Jacob", "Jacob", "Alice"] as Array[String]
## dialogue_faces = [load("res://faces/j/happy.png"), load("res://faces/j/normal.png"), load("res://faces/a/happy.png")] as Array[CompressedTexture2D]
## dialogue_voices = [load("res://dialogue_voice.ogg")] as Array[AudioStream]
## start_dialogue()
## [/codeblock]
class_name DialogBox

signal resetting(use_names: DialogueNames, use_faces: bool, use_voices: DialogueVoices) ## Signal for changing settings of box.
signal trigger_pressed ## Signal which emit's when [input_trigger] is pressed (only if [input_use_trigger] is [code]true[/code]).
signal dialogue_ended ## Signal which emit's when dialogue is ends.

enum DialogueNames {
	NO, ## No names.
	MONOLOGUE, ## Single speaker for each text line.
	DIALOGUE ## Two and more speakers for text lines.
}
enum DialogueVoices {
	NO, ## No voice lines.
	SINGLE, ## Single voice line for each text line.[br]Recommendation: loop your [AudioStream] file.
	EACH_LINE ## Several voice lines for each text line.[br]Recommendation: don't loop your [AudioStream] file.
}

var bg_image: TextureRect = TextureRect.new()
var bg_rim: TextureProgressBar = TextureProgressBar.new()
var speaker: VSplitContainer = VSplitContainer.new()
var name: Label = Label.new()
var speaking: HSplitContainer = HSplitContainer.new()
var lines: RichTextLabel = RichTextLabel.new()
var face: TextureRect = TextureRect.new()
var voice: AudioStreamPlayer = AudioStreamPlayer.new()

@export var continue_timer: float = 1.0 ## If [member input_use_trigger] is [code]false[/code], after this time speaking will continue.

## Texture of the backgroung of the dialog box.
@export var bg_texture: Texture2D:
	set(value): $BackgroundImage.texture = value

@export_group("Text", "text_")
## Font for text in dialogues.
@export var text_font: Font = SystemFont.new():
	set(value):
		text_font = value
		$Speaker/Name.add_theme_font_override("font", value)
		$Speaker/Speaking/Text.add_theme_font_override("normal_font", value)
		$Speaker/Speaking/Text.add_theme_font_override("bold_font", value)
		$Speaker/Speaking/Text.add_theme_font_override("italics_font", value)
		$Speaker/Speaking/Text.add_theme_font_override("bold_italics_font", value)
		$Speaker/Speaking/Text.add_theme_font_override("mono_font", value)

## Text size in pixels for text in dialogues.
@export var text_size: int = 16:
	set(value):
		text_size = value
		$Speaker/Speaking/Text.add_theme_font_size_override("normal_font_size", value)
		$Speaker/Speaking/Text.add_theme_font_size_override("bold_font_size", value)
		$Speaker/Speaking/Text.add_theme_font_size_override("italics_font_size", value)
		$Speaker/Speaking/Text.add_theme_font_size_override("bold_italics_font_size", value)
		$Speaker/Speaking/Text.add_theme_font_size_override("mono_font_size", value)

## Color for text in dialogues.
@export var text_color: Color = Color.WHITE:
	set(value): text_color = value; $Speaker/Speaking/Text.add_theme_color_override("default_color", value)

## Color for name in dialogues.
@export var text_name_color: Color = Color.WHITE:
	set(value): text_name_color = value; $Speaker/Name.add_theme_color_override("font_color", value)

## Text size in pixels for name in dialogues.
@export var text_name_size: int = 27:
	set(value): text_name_size = value; $Speaker/Name.add_theme_font_size_override("font_size", value)

@export var text_characters_per_second: int = 10 ## Amount of characters (symbols) showed per second.
@export var text_speed: float = 1.0 ## Speed scale for text lines in dialogues.

@export_group("Input", "input_")
## If [code]true[/code], you'll need to trigger action [member input_trigger] for continue speaking.
@export var input_use_trigger: bool = false:
	set(value):
		input_use_trigger = value
		if !input_use_trigger: input_trigger = ""

## If setted, triggering of this action will continue speaking.
@export var input_trigger: StringName = &"":
	set(value): if input_use_trigger: input_trigger = value

@export_group("Dialogue", "dialogue_")
## Text lines.
@export var dialogue_lines: Array[String] = []:
	set(value):
		dialogue_lines = value
		if dialogue_use_names == DialogueNames.DIALOGUE: dialogue_names.resize(dialogue_lines.size())
		if dialogue_use_faces: dialogue_faces.resize(dialogue_lines.size())
		if dialogue_use_voices == DialogueVoices.EACH_LINE: dialogue_voices.resize(dialogue_lines.size())

## If [code]not DialogueNames.NO[/code], you'll see speaker's name.
@export var dialogue_use_names: DialogueNames = DialogueNames.NO:
	set(value):
		dialogue_use_names = value
		match value:
			DialogueNames.NO: dialogue_names.clear()
			DialogueNames.MONOLOGUE: dialogue_names.resize(1)

## If [member dialogue_use_names] is [code]not DialogueNames.NO[/code] and setted for current frame, shows speaker's name. More in [enum DialogueNames].
@export var dialogue_names: Array[String] = []:
	set(value): if dialogue_use_names != DialogueNames.NO:
		dialogue_names = value
		if dialogue_use_names == DialogueNames.MONOLOGUE: dialogue_names.resize(1)

## If [code]true[/code], you'll see speaker's face if setted on current frame in [member dialogue_faces].
@export var dialogue_use_faces: bool = false:
	set(value):
		dialogue_use_faces = value
		if !dialogue_use_faces and dialogue_faces.size() > 0: dialogue_faces.clear()

## If [member dialogue_use_faces] is [code]true[/code] and setted for current frame, shows speaker's face.
@export var dialogue_faces: Array[CompressedTexture2D] = []:
	set(value): if dialogue_use_faces: dialogue_faces = value

## If [code]not DialogueVoices.NO[/code], you'll hear voice of speaker if setted in [member dialogue_voices].
@export var dialogue_use_voices: DialogueVoices = DialogueVoices.NO:
	set(value):
		dialogue_use_voices = value
		match value:
			DialogueVoices.NO: dialogue_voices.clear()
			DialogueVoices.SINGLE: dialogue_voices.resize(1)

## If [member dialogue_use_voices] is [code]not DialogueVoices.NO[/code] and setted for current frame, starts the voice of the speaker. More in [enum DialogueVoices].
@export var dialogue_voices: Array[AudioStream] = []:
	set(value): if dialogue_use_voices != DialogueVoices.NO:
		dialogue_voices = value
		if dialogue_use_voices == DialogueVoices.SINGLE: dialogue_voices.resize(1)

func _enter_tree() -> void: pass
#add_child(bg_image)
#add_child(bg_rim)
#add_child(speaker)
#speaker.add_child(name)
#speaker.add_child(speaking)
#speaking.add_child(lines)
#speaking.add_child(face)
#speaking.add_child(voice)

func _input(event: InputEvent) -> void: if input_use_trigger and input_trigger != "":
	if InputMap.action_get_events(input_trigger)[0].as_text() == event.as_text(): emit_signal("trigger_pressed")

func _on_resetting(use_names: DialogueNames, use_faces: bool, use_voices: DialogueVoices) -> void:
	dialogue_use_names = use_names; dialogue_use_faces = use_faces; dialogue_use_voices = use_voices
	$Speaker/Speaking/Face.visible = dialogue_use_faces

## Function for showing text lines and other: [member dialogue_names], [member dialogue_faces], and [member dialogue_voices].
func start_dialogue():
	var frame: int = 0
	$Speaker/Name.text = ""
	
	for line in dialogue_lines:
		#Preparing
		$Speaker/Speaking/Text.text = line
		$Speaker/Speaking/Text.visible_characters = 0
		if dialogue_use_faces: $Speaker/Speaking/Face.texture = dialogue_faces[frame]
#		if dialogue_use_names != DialogueNames.NO:
		match dialogue_use_names:
			DialogueNames.MONOLOGUE: $Speaker/Name.text = dialogue_names[0]
			DialogueNames.DIALOGUE: $Speaker/Name.text = dialogue_names[frame]
		match dialogue_use_voices:
			DialogueVoices.NO: $Speaker/Speaking/Voice.stream = null
			DialogueVoices.SINGLE: $Speaker/Speaking/Voice.stream = dialogue_voices[0]
			DialogueVoices.EACH_LINE: $Speaker/Speaking/Voice.stream = dialogue_voices[frame]
		#Printing
		$Speaker/Speaking/Voice.playing = true
		print("\"" + $Speaker/Name.text +"\": \"" + line +"\"")
		for char in line.split():
			$Speaker/Speaking/Text.visible_characters += 1
			await get_tree().create_timer(1/text_characters_per_second*text_speed).timeout
		#Transition
		if input_use_trigger: await self.trigger_pressed
		else: await get_tree().create_timer(continue_timer).timeout
		frame += 1
	$Speaker/Speaking/Voice.playing = false
	$Speaker/Speaking/Voice.stream = null
	$Speaker/Speaking/Face.texture = null
	$Speaker/Name.text = ""
	$Speaker/Speaking/Text.text = ""
