class_name Dialog
extends Resource

## Enumeration for setting VA type.
enum VoiceActingMode {
	NO, ## No VA. There will be no sound while character(s) are talking.
	PARTICALLY, ## Partically VA. This means just voices such as beeping, etc.
	FULL ## Full VA. This means voiced dialogue lines and like that.
}

## Enumiration for setting sequence of finished voice. Works only for [member voice_acting_mode] setted to [code]VoiceActingMode.FULL[/code].
enum VoiceSequence {
	NO, ## No special sequence.
	TIMER_TRANSIT, ## After finished dialogue voice line dialog transits to next line or will activate branch after contimue timer's timeout.
	TRANSIT ## After finished dialogue voice line dialog automaticly transits to next line or will activate branch.
}

@export var id: int ## Dialogue's unique ID.
@export var voice_acting_mode: VoiceActingMode = VoiceActingMode.NO
@export var voice_ending_sequence: VoiceSequence = VoiceSequence.NO
@export var branching_use: bool ## If [code]true[/code], adds branching.[br]Adds exetnal unit in active dialogue members that allows you to customize question's style.

@export var containment: Array[DialogUnit]
@export var branching_variants: Array[DialogueBranchVariant] #Всегда ставится в последнюю фразу.
