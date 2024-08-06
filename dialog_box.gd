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

## Enumeration for setting design mode of the Dialog box.
enum DesignMode {
	NO, ## No background image nor rim.
	IMAGE, ## Adds background image for box which texture sets in [member texture_bg_image].
	RIM, ## Adds rim around box which texture sets in [member texture_rim]
	BOTH ## Adds both background image and rim for box which textures sets in [member texture_bg_image] and [member texture_rim] respectively.
}

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
var name_dialoque: Label = Label.new()
var speaking: HSplitContainer = HSplitContainer.new()
var lines_dialoque: RichTextLabel = RichTextLabel.new()
var face_dialoque: TextureRect = TextureRect.new()
var voice_dialoque: AudioStreamPlayer = AudioStreamPlayer.new()

@export_group("Settings")

@export var design_mode: DesignMode = DesignMode.NO:
	set(value):
		design_mode = value
		match value:
			DesignMode.NO:
				bg_image.hide()
				bg_rim.hide()
			DesignMode.IMAGE:
				bg_image.show()
				bg_rim.hide()
			DesignMode.RIM:
				bg_image.hide()
				bg_rim.show()
			DesignMode.BOTH:
				bg_image.show()
				bg_rim.show()

@export var rim_scale: Vector2 = Vector2.ONE:
	set(value):
		rim_scale = value
		bg_rim.scale = value
	
@export_subgroup("Backgroung textures", "bg_texture_")
## Texture of the backgroung image of the dialog box.
@export var bg_texture_image: Texture2D:
	set(value):
		bg_texture_image = value
		bg_image.texture = value

## Texture of the rim of the dialog box.
@export var bg_texture_rim: Texture2D:
	set(value):
		bg_texture_rim = value
		bg_rim.texture_under = value


@export_group("Functionality")

@export var continue_timer: float = 1.0 ## If [member input_use_trigger] is [code]false[/code], after this time speaking will continue.

@export_subgroup("Text", "text_")
## Font for text in dialogues.
@export var text_font: Font = SystemFont.new():
	set(value):
		text_font = value
		name_dialoque.add_theme_font_override("font", value)
		lines_dialoque.add_theme_font_override("normal_font", value)
		lines_dialoque.add_theme_font_override("bold_font", value)
		lines_dialoque.add_theme_font_override("italics_font", value)
		lines_dialoque.add_theme_font_override("bold_italics_font", value)
		lines_dialoque.add_theme_font_override("mono_font", value)

## Text size in pixels for text in dialogues.
@export var text_size: int = 16:
	set(value):
		text_size = value
		lines_dialoque.add_theme_font_size_override("normal_font_size", value)
		lines_dialoque.add_theme_font_size_override("bold_font_size", value)
		lines_dialoque.add_theme_font_size_override("italics_font_size", value)
		lines_dialoque.add_theme_font_size_override("bold_italics_font_size", value)
		lines_dialoque.add_theme_font_size_override("mono_font_size", value)

## Color for text in dialogues.
@export var text_color: Color = Color.WHITE:
	set(value): text_color = value; lines_dialoque.add_theme_color_override("default_color", value)

## Color for name in dialogues.
@export var text_name_color: Color = Color.WHITE:
	set(value): text_name_color = value; name_dialoque.add_theme_color_override("font_color", value)

## Text size in pixels for name in dialogues.
@export var text_name_size: int = 27:
	set(value): text_name_size = value; name_dialoque.add_theme_font_size_override("font_size", value)

@export var text_characters_per_second: int = 10 ## Amount of characters (symbols) showed per second.
@export var text_speed: float = 1.0 ## Speed scale for text lines in dialogues.

@export_subgroup("Input", "input_")
## If [code]true[/code], you'll need to trigger action [member input_trigger] for continue speaking.
@export var input_use_trigger: bool = false:
	set(value):
		input_use_trigger = value
		if !input_use_trigger: input_trigger = ""

## If setted, triggering of this action will continue speaking.
@export var input_trigger: StringName = &"":
	set(value): if input_use_trigger: input_trigger = value

@export_subgroup("Dialogue", "dialogue_")
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

func _enter_tree() -> void:#if get_children().size <= 0:
	
	#Adding nodes
	add_child(bg_image)
	add_child(bg_rim)
	add_child(speaker)
	speaker.add_child(name_dialoque)
	speaker.add_child(speaking)
	speaking.add_child(lines_dialoque)
	speaking.add_child(face_dialoque)
	speaking.add_child(voice_dialoque)
	
	#Naming nodes
	bg_image.name = "BG Image"
	bg_rim.name = "BG Rim"
	speaker.name = "Speaker"
	name_dialoque.name = "Name"
	speaking.name = "Speaking"
	lines_dialoque.name = "Lines"
	face_dialoque.name = "Face"
	voice_dialoque.name = "Voice"
	
	#Undeniable settings
	bg_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	bg_rim.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_rim.nine_patch_stretch = true
	bg_rim.stretch_margin_left = 15
	bg_rim.stretch_margin_top = 15
	bg_rim.stretch_margin_right = 15
	bg_rim.stretch_margin_bottom = 15
	
	speaker.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED
	speaker.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	name_dialoque.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	name_dialoque.size_flags_stretch_ratio = 0
	
	speaking.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED
	speaking.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	
	lines_dialoque.bbcode_enabled = true
	lines_dialoque.scroll_active = false
	lines_dialoque.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	face_dialoque.stretch_mode = TextureRect.STRETCH_KEEP
	face_dialoque.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	face_dialoque.size_flags_stretch_ratio = 0
	
	#Conecting signals
	resized.connect(_resized.bind())

func _resized(): bg_rim.pivot_offset = size / 2

func _input(event: InputEvent) -> void: if input_use_trigger and input_trigger != "":
	if InputMap.action_get_events(input_trigger)[0].as_text() == event.as_text(): emit_signal("trigger_pressed")

## Function for showing text lines and other: [member dialogue_names], [member dialogue_faces], and [member dialogue_voices].
func start_dialogue():
	var frame: int = 0
	name_dialoque.text = ""
	
	for line in dialogue_lines:
		#Preparing
		lines_dialoque.text = line
		lines_dialoque.visible_characters = 0
		if dialogue_use_faces: face_dialoque.texture = dialogue_faces[frame]
#		if dialogue_use_names != DialogueNames.NO:
		match dialogue_use_names:
			DialogueNames.MONOLOGUE: name_dialoque.text = dialogue_names[0]
			DialogueNames.DIALOGUE: name_dialoque.text = dialogue_names[frame]
		match dialogue_use_voices:
			DialogueVoices.NO: voice_dialoque.stream = null
			DialogueVoices.SINGLE: voice_dialoque.stream = dialogue_voices[0]
			DialogueVoices.EACH_LINE: voice_dialoque.stream = dialogue_voices[frame]
		#Printing
		voice_dialoque.playing = true
		print("\"" + name_dialoque.text +"\": \"" + line +"\"")
		for char in line.split():
			lines_dialoque.visible_characters += 1
			await get_tree().create_timer(1/text_characters_per_second*text_speed).timeout
		#Transition
		if input_use_trigger: await self.trigger_pressed
		else: await get_tree().create_timer(continue_timer).timeout
		frame += 1
	voice_dialoque.playing = false
	voice_dialoque.stream = null
	face_dialoque.texture = null
	name_dialoque.text = ""
	lines_dialoque.text = ""
