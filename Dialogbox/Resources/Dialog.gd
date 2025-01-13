@tool
class_name Dialog
extends Resource

@export var id: int
@export var branching_use: bool ## If [code]true[/code], adds branching.[br]Adds exetnal unit in active dialogue members that allows you to customize question's style.

@export var containment: Array[DialogUnit]
@export var branching_variants: Array[DialogueBranchVariant] #Всегда ставится в последнюю фразу.
