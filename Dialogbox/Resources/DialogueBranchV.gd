@tool
class_name DialogueBranchVariant extends Resource

signal selected(id: int)

@export var text: String
@export var output_id: int ## Outputing ID for identifying selected variant.
