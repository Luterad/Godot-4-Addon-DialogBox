@tool
class_name DialoguesLines extends Resource

@export var id: int
@export_multiline var lines: Array[String]

@export_group("Branching", "branching_")

## If [code]true[/code], adds branching.[br]Adds exetnal unit in active dialogue members that allows you to customize question's style.
@export var branching_use: bool
@export var branching_variants: Array[DialogueBranchVariant] #Всегда ставится в последнюю фразу.
