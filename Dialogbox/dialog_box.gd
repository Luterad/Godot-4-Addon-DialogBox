@tool
@icon("res://addons/Godot-4-Addon-DialogBox/Dialogbox/icon.png")
class_name DialogBox extends Control

## Custom class for easy dialogues.
## 
## DialogBox is custom class for fast creating game dialogues.[br]
## For starting of speaking you'll need to set some dialogues in [member dialogues] via redactor.

signal trigger_pressed ## Emit's when [input_trigger] is pressed (only if [member input_use_trigger] is [code]true[/code]).
signal line_ended ## Emit's when dialogue line is ends.
signal branch_variant_selected(dialogue_id: int, variant_id: int) ## Emit's when branch variant is selected and basicly used for emiting other dialogues via idenifying them with IDs.
signal dialogue_started(id: int) ## Emit's when dialogue is starts.
signal dialogue_ended(id: int) ## Emit's when dialogue is ends.
signal dialogue_line_skipped(dialog_id: int) ## Emit's when [member input_skip] is pressed (only if [member input_use_skip] is [code]true[/code]).

## Enumeration for setting design mode of the Dialog box.
enum DesignMode {
	NO, ## No background image nor rim.
	IMAGE, ## Adds background image for box which texture sets in [member texture_bg_image].
	RIM, ## Adds rim around box which texture sets in [member texture_rim]
	BOTH ## Adds both background image and rim for box which textures sets in [member texture_bg_image] and [member texture_rim] respectively.
}
#region Nodes
var bg_image: TextureRect = TextureRect.new() ## Background image of the dialog box.
var bg_rim: TextureProgressBar = TextureProgressBar.new() ## Rim for rimming of dialog box.
var speaker: VSplitContainer = VSplitContainer.new() ## Container of name of the character and dialogue lines, faces and voice, contained in [member speaking] container.
var name_dialogue: Label = Label.new() ## Speaker's name.
var speaking: HSplitContainer = HSplitContainer.new() ## Container of dialogue lines, faces and voices of character(s).
var branching: VSplitContainer = VSplitContainer.new() ## Container of dialogue lines and branch variants.
var lines_dialogue: RichTextLabel = RichTextLabel.new() ## Node for showing main text of the dialogue.
var branch_variants: VBoxContainer = VBoxContainer.new() ## Container of branching variants.
var face_dialogue: TextureRect = TextureRect.new() ## Node for showing setted face of the character in dialogue.
var voice_dialogue: AudioStreamPlayer = AudioStreamPlayer.new() ## Node for playing voice of character(s).
#endregion
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

## Allows text to use translation if [code]true[/code].
@export var use_translation: bool = false

#region Background settings
@export_subgroup("Background textures", "bg_texture_")
## Texture of the background image of the dialog box.
@export var bg_texture_image: Texture2D:
	set(value):
		bg_texture_image = value
		bg_image.texture = value

## Texture of the rim of the dialog box.
@export var bg_texture_rim: Texture2D:
	set(value):
		bg_texture_rim = value
		bg_rim.texture_under = value

## Scale of box's rim.
@export_custom(PROPERTY_HINT_LINK, "") var bg_texture_rim_scale: Vector2 = Vector2.ONE:
	set(value):
		bg_texture_rim_scale = value
		bg_rim.scale = value
#endregion
#region Name settings
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
#endregion
#region Face settings
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
#endregion
#region Stretching variables
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
#endregion

@export_group("Functionality")

@export var continue_timer: float = 1.0 ## If [member input_use_trigger] is [code]false[/code], after this time speaking will continue.

#region Text-related variables
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
@export var text_size: int:
	set(value):
		text_size = value
		lines_dialogue.add_theme_font_size_override("normal_font_size", value)
		lines_dialogue.add_theme_font_size_override("bold_font_size", value)
		lines_dialogue.add_theme_font_size_override("italics_font_size", value)
		lines_dialogue.add_theme_font_size_override("bold_italics_font_size", value)
		lines_dialogue.add_theme_font_size_override("mono_font_size", value)

## Text size in pixels for name in dialogues.
@export var text_name_size: int:
	set(value):
		text_name_size = value
		name_dialogue.add_theme_font_size_override("font_size", value)

@export var text_characters_per_second: int = 10 ## Amount of characters (symbols) showed per second.
@export var text_speed: float = 1.0 ## Speed scale for text lines in dialogues.
#endregion
#region Input variables
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
#endregion

@export var dialogues: Array[Dialog] ## Contains every dualogue.

func _enter_tree() -> void:
	#region Adding nodes
	add_child(bg_image)
	add_child(bg_rim)
	add_child(speaker)
	speaker.add_child(name_dialogue)
	speaker.add_child(speaking)
	speaking.add_child(branching)
	branching.add_child(lines_dialogue)
	branching.add_child(branch_variants)
	speaking.add_child(face_dialogue)
	speaking.add_child(voice_dialogue)
	#endregion
	#region Naming nodes
	bg_image.name = "BG Image"
	bg_rim.name = "BG Rim"
	speaker.name = "Speaker"
	name_dialogue.name = "Name"
	speaking.name = "Speaking"
	branching.name = "Branching"
	lines_dialogue.name = "Lines"
	branch_variants.name = "Variants"
	face_dialogue.name = "Face"
	voice_dialogue.name = "Voice"
	#endregion
	#region Undeniable settings
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
	name_dialogue.uppercase = name_uppercase
	
	speaking.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED
	speaking.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	
	branching.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED
	branching.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	lines_dialogue.bbcode_enabled = true
	lines_dialogue.scroll_active = false
	lines_dialogue.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	lines_dialogue.size_flags_stretch_ratio = 1
	
	branch_variants.size_flags_stretch_ratio = 0
	branch_variants.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	
	face_dialogue.stretch_mode = TextureRect.STRETCH_KEEP
	face_dialogue.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	face_dialogue.size_flags_stretch_ratio = 0
	#endregion
	#region Conecting signals
	resized.connect(_resized.bind())
	#endregion

func _resized(): bg_rim.pivot_offset = size / 2

func _process(delta: float) -> void:
	if input_use_trigger and input_trigger != &"" and InputMap.has_action(input_trigger):
		if Input.is_action_just_pressed(input_trigger): trigger_pressed.emit()
	if input_use_skip and input_skip != &"" and InputMap.has_action(input_skip):
		if Input.is_action_just_pressed(input_skip):
			if lines_dialogue.visible_characters > 1 and lines_dialogue.visible_ratio < 1:
				dialogue_line_skipped.emit()
				lines_dialogue.visible_ratio = 1

## Function for showing text lines and other: [member dialogue_names], [member dialogue_faces], and [member dialogue_voices].
func start_dialogue(id: int = 0):
	#region Setuping
	await get_tree().process_frame
	dialogue_started.emit(id)
	show()
	var dialogue: Dialog
	var frame: int = 0
	name_dialogue.text = ""
	
	for d in dialogues: if d.id == id: dialogue = d; break
	if dialogue.branching_use: for variant in dialogue.branching_variants:
			var button: Button = Button.new()
			branch_variants.add_child(button)
			button.disabled = true
			button.name = "Variant1"
			button.text = variant.text
			button.editor_description = str(id)
			button.pressed.connect(_variant_selected.bind(button, variant.output_id))
			button.hide()
			button = null
	#endregion
	for unit in dialogue.containment:
	#region Preparing
		lines_dialogue.text = unit.line
		lines_dialogue.visible_characters = 0
		if unit.face: face_dialogue.texture = unit.face
		if unit.name: name_dialogue.text = unit.name
		if unit.voice: voice_dialogue.stream = unit.voice
	#endregion
	#region Printing
		voice_dialogue.playing = true
		print("\"", name_dialogue.text, "\": \"", unit.line, "\"")
		if use_translation:
			for char in String(TranslationServer.translate(unit.line)).split():
				lines_dialogue.visible_characters += 1
				await get_tree().create_timer(1/text_characters_per_second*text_speed).timeout
		else:
			for char in unit.line.split():
				lines_dialogue.visible_characters += 1
				await get_tree().create_timer(1/text_characters_per_second*text_speed).timeout
	#endregion
	#region Transition
		if dialogue.containment[-1] == unit && dialogue.branching_use:
			for button in branch_variants.get_children():
				button.show()
				button.disabled = false
			await branch_variant_selected
		else:
			if dialogue.voice_acting_mode == Dialog.VoiceActingMode.FULL && dialogue.voice_ending_sequence != Dialog.VoiceSequence.NO:
				await voice_dialogue.finished
				if dialogue.voice_ending_sequence == Dialog.VoiceSequence.TIMER_TRANSIT: await get_tree().create_timer(continue_timer).timeout
			else:
				if dialogue.voice_acting_mode == Dialog.VoiceActingMode.PARTICALLY: voice_dialogue.stop()
				if input_use_trigger: await self.trigger_pressed
				else: await get_tree().create_timer(continue_timer).timeout
		line_ended.emit(id)
		frame += 1
	#endregion
	for variant in branch_variants.get_children(): variant.queue_free()
	
	voice_dialogue.playing = false
	voice_dialogue.stream = null
	face_dialogue.texture = null
	name_dialogue.text = ""
	lines_dialogue.text = ""
	dialogue_ended.emit(id)
	hide()

func _variant_selected(button: Button, var_id: int) -> void:
	print("Player: \"%s\"" % button.text)
	branch_variant_selected.emit(button.editor_description.to_int(), var_id)
