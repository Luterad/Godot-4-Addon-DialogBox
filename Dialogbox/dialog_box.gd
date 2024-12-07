@tool
@icon("res://addons/Godot-4-Addon-DialogBox/Dialogbox/icon.png")
class_name DialogBox extends Control #EditorPlugin

## Custom class for easy dialogues.
## 
## DialogBox is custom class for fast creating game dialogues.[br]
## For starting of speaking you'll need to set some dialogues in [code]Dialogue[/code] subgroup via redactor.

signal trigger_pressed ## Signal which emit's when [input_trigger] is pressed (only if [member input_use_trigger] is [code]true[/code]).
signal line_ended ## Signal which emit's when dialogue line is ends.
signal dialogue_ended ## Signal which emit's when dialogue is ends.
signal dialogue_line_skipped ## Signal which emit's when [member input_skip] is pressed (only if [member input_use_skip] is [code]true[/code]).

## Enumeration for setting design mode of the Dialog box.
enum DesignMode {
	NO, ## No background image nor rim.
	IMAGE, ## Adds background image for box which texture sets in [member texture_bg_image].
	RIM, ## Adds rim around box which texture sets in [member texture_rim]
	BOTH ## Adds both background image and rim for box which textures sets in [member texture_bg_image] and [member texture_rim] respectively.
}

var bg_image: TextureRect = TextureRect.new() ## Backgroung image of the dialog box.
var bg_rim: TextureProgressBar = TextureProgressBar.new() ## Rim for rimming of dialog box.
var speaker: VSplitContainer = VSplitContainer.new() ## Container of name of the character and dialogue lines, faces and voice, contained in [member speaking] container.
var name_dialogue: Label = Label.new() ## Speaker's name.
var speaking: HSplitContainer = HSplitContainer.new() ## Container of dialogue lines, faces and voice of character(s).
var lines_dialogue: RichTextLabel = RichTextLabel.new() ## Node for showing main text of the dialogue.
var face_dialogue: TextureRect = TextureRect.new() ## Node for showing setted face of the character in dialogue.
var voice_dialogue: AudioStreamPlayer = AudioStreamPlayer.new() ## Node for playing voice of character(s).

@export_group("Settings")

## Design of the box. Uses to show either background image or rim, either none or all of them.
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

## Scale of box's rim.
@export var rim_scale: Vector2 = Vector2.ONE:
	set(value):
		rim_scale = value
		bg_rim.scale = value

## Allows text to use translation if [code]true[/code].
@export var use_translation: bool = false

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

@export_subgroup("Name", "name_")

## Name's vertical alignment.
@export var name_alignment_v: VerticalAlignment = VERTICAL_ALIGNMENT_TOP:
	set(value):
		name_alignment_v = value
		name_dialogue.vertical_alignment = value

## Name's horizontal alignment.
@export var name_alignment_h: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT:
	set(value):
		name_alignment_h = value
		name_dialogue.horizontal_alignment = value

## If [code]true[/code], Name's text will be uppercase.
@export var name_uppercase: bool = false:
	set(value):
		name_uppercase = value
		name_dialogue.uppercase = value

@export_subgroup("Face", "face_")

## Face's [member TextureRect.flip_h].
@export var face_flip_horizontal: bool = false:
	set(value):
		face_flip_horizontal = value
		face_dialogue.flip_h = value

## Face's [member TextureRect.flip_v].
@export var face_flip_vertical: bool = false:
	set(value):
		face_flip_vertical = value
		face_dialogue.flip_v = value

@export_subgroup("Stretch ratios", "stretch_ratio_")

## Stretching of area of name (in a [member stretch_ratio_name]:[member stretch_ratio_speaking] ratio). If [code]0[/code], then name will take as much space as it needs.
@export_range(0, 4, 0.05, "or_greater") var stretch_ratio_name: float = 0:
	set(value):
		stretch_ratio_name = value
		name_dialogue.size_flags_stretch_ratio = value

## Stretching of area of speaking area (dialogue lines & face) (in a [member stretch_ratio_name]:[member stretch_ratio_speaking] ratio). If [code]0[/code], then speaker area will take as much space as it needs.
@export_range(0, 4, 0.05, "or_greater") var stretch_ratio_speaking: float = 1:
	set(value):
		stretch_ratio_speaking = value
		speaking.size_flags_stretch_ratio = value

## Stretching of area of lines area (in a [member stretch_ratio_lines]:[member stretch_ratio_face] ratio). If [code]0[/code], then lines will take as much space as it needs.
@export_range(0, 4, 0.05, "or_greater") var stretch_ratio_lines: float = 1:
	set(value):
		stretch_ratio_lines = value
		lines_dialogue.size_flags_stretch_ratio = value

## Stretching of area of face area (in a [member stretch_ratio_lines]:[member stretch_ratio_face] ratio). If [code]0[/code], then face will take as much space as it needs.
@export_range(0, 4, 0.05, "or_greater") var stretch_ratio_face: float = 0:
	set(value):
		stretch_ratio_face = value
		face_dialogue.size_flags_stretch_ratio = value


@export_group("Functionality")

@export var continue_timer: float = 1.0 ## If [member input_use_trigger] is [code]false[/code], after this time speaking will continue.

@export_subgroup("Text", "text_")
## Font for text in dialogues.
@export var text_font: Font = SystemFont.new():
	set(value):
		text_font = value
		name_dialogue.add_theme_font_override("font", value)
		lines_dialogue.add_theme_font_override("normal_font", value)
		lines_dialogue.add_theme_font_override("bold_font", value)
		lines_dialogue.add_theme_font_override("italics_font", value)
		lines_dialogue.add_theme_font_override("bold_italics_font", value)
		lines_dialogue.add_theme_font_override("mono_font", value)

## Color for text in dialogues.
@export var text_color: Color = Color.WHITE:
	set(value): text_color = value; lines_dialogue.add_theme_color_override("default_color", value)

## Color for name in dialogues.
@export var text_name_color: Color = Color.WHITE:
	set(value): text_name_color = value; name_dialogue.add_theme_color_override("font_color", value)

## Text size in pixels for text in dialogues.
@export var text_size: int = 16:
	set(value):
		lines_dialogue.add_theme_font_size_override("normal_font_size", value)
		lines_dialogue.add_theme_font_size_override("bold_font_size", value)
		lines_dialogue.add_theme_font_size_override("italics_font_size", value)
		lines_dialogue.add_theme_font_size_override("bold_italics_font_size", value)
		lines_dialogue.add_theme_font_size_override("mono_font_size", value)

## Text size in pixels for name in dialogues.
@export var text_name_size: int = 27:
	set(value): text_name_size = value; name_dialogue.add_theme_font_size_override("font_size", value)

@export var text_characters_per_second: int = 10 ## Amount of characters (symbols) showed per second.
@export var text_speed: float = 1.0 ## Speed scale for text lines in dialogues.

@export_subgroup("Inputs", "input_")
## If [code]true[/code], you'll need to trigger action [member input_trigger] for continue speaking.
@export var input_use_trigger: bool = false:
	set(value):
		if !value: input_trigger = &""
		input_use_trigger = value

## If setted, triggering of this action will continue speaking.
@export var input_trigger: StringName = &"":
	set(value): if input_use_trigger: input_trigger = value

##If [code]true[/code], you'll be able to press action [member input_skip] to skip dialogue's animation and immediately end current line.
@export var input_use_skip: bool = false:
	set(value):
		if !value: input_skip = &""
		input_use_skip = value

##If setted, triggering of this action will skip dialogue's animation and immediately end current line.[br][b]Must[/b] be build-in action.
@export var input_skip: StringName = &"":
	set(value): if input_use_skip: input_skip = value

@export_subgroup("Dialogue", "dialogue_")
## Text lines.
@export var dialogue_lines: Array[DialoguesLines]
@export var dialogue_names: Array[DialoguesNames]
@export var dialogue_faces: Array[DialoguesFaces]
@export var dialogue_voices: Array[DialoguesVoices]

## If [code]true[/code], adds branching.[br]Adds exetnal unit in active dialogue members that allows you to customize question's style.
#@export var dialogue_use_branching: bool

func _enter_tree() -> void:
	#Adding nodes
	add_child(bg_image)
	add_child(bg_rim)
	add_child(speaker)
	speaker.add_child(name_dialogue)
	speaker.add_child(speaking)
	speaking.add_child(lines_dialogue)
	speaking.add_child(face_dialogue)
	speaking.add_child(voice_dialogue)
	
	#Naming nodes
	bg_image.name = "BG Image"
	bg_rim.name = "BG Rim"
	speaker.name = "Speaker"
	name_dialogue.name = "Name"
	speaking.name = "Speaking"
	lines_dialogue.name = "Lines"
	face_dialogue.name = "Face"
	voice_dialogue.name = "Voice"
	
	#Undeniable settings
	bg_image.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	
	bg_rim.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	bg_rim.nine_patch_stretch = true
	bg_rim.stretch_margin_left = 15
	bg_rim.stretch_margin_top = 15
	bg_rim.stretch_margin_right = 15
	bg_rim.stretch_margin_bottom = 15
	
	speaker.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED
	speaker.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	
	name_dialogue.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	name_dialogue.size_flags_stretch_ratio = 0
	
	speaking.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED
	speaking.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	
	lines_dialogue.bbcode_enabled = true
	lines_dialogue.scroll_active = false
	lines_dialogue.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	face_dialogue.stretch_mode = TextureRect.STRETCH_KEEP
	face_dialogue.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	face_dialogue.size_flags_stretch_ratio = 0
	
	#Conecting signals
	resized.connect(_resized.bind())

func _resized(): bg_rim.pivot_offset = size / 2

func _process(delta: float) -> void:
	if input_use_trigger and input_trigger != &"" and Input.is_action_just_pressed(input_trigger): trigger_pressed.emit()
	if input_use_skip and input_skip != &"" and Input.is_action_just_pressed(input_skip):
		if lines_dialogue.visible_characters > 1 and lines_dialogue.visible_ratio < 1:
			dialogue_line_skipped.emit()
			lines_dialogue.visible_ratio = 1

## Function for showing text lines and other: [member dialogue_names], [member dialogue_faces], and [member dialogue_voices].
func start_dialogue(id: int = 0):
	show()
	var frame: int = 0
	var lines: DialoguesLines
	var names: DialoguesNames
	var faces: DialoguesFaces
	var voices: DialoguesVoices
	name_dialogue.text = ""
	
	#Searching needed dialogue
	for dialogue in dialogue_lines:
		if dialogue.id == id:
			lines = dialogue
			break
	for _name in dialogue_names:
		if _name.id == id:
			names = _name
			break
	for face in dialogue_faces:
		if face.id == id:
			faces = face
			break
	for voice in dialogue_voices:
		if voice.id == id:
			voices = voice
			break
	
	for line in lines.lines:
		#Preparing
		lines_dialogue.text = line
		lines_dialogue.visible_characters = 0
		if faces && faces.use: face_dialogue.texture = faces.faces[frame]
		if names: match names.dialogue_type:
			DialoguesNames.DialogueNames.MONOLOGUE: name_dialogue.text = names.names[0]
			DialoguesNames.DialogueNames.DIALOGUE: name_dialogue.text = names.names[frame]
		if voices: match voices.use:
			DialoguesVoices.DialogueVoices.NO: voice_dialogue.stream = null
			DialoguesVoices.DialogueVoices.SINGLE: voice_dialogue.stream = voices.voices[0]
			DialoguesVoices.DialogueVoices.EACH_LINE: voice_dialogue.stream = voices.voices[frame]
		#Printing
		voice_dialogue.playing = true
		print("\"", name_dialogue.text, "\": \"", line, "\"")
		if use_translation:
			for char in String(TranslationServer.translate(line)).split():
				lines_dialogue.visible_characters += 1
				await get_tree().create_timer(1/text_characters_per_second*text_speed).timeout
		else:
			for char in line.split():
				lines_dialogue.visible_characters += 1
				await get_tree().create_timer(1/text_characters_per_second*text_speed).timeout
		#Transition
		if input_use_trigger: await self.trigger_pressed
		else: await get_tree().create_timer(continue_timer).timeout
		line_ended.emit()
		frame += 1
	voice_dialogue.playing = false
	voice_dialogue.stream = null
	face_dialogue.texture = null
	name_dialogue.text = ""
	lines_dialogue.text = ""
	dialogue_ended.emit()
	hide()
