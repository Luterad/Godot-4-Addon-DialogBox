@tool
class_name DialoguesFaces extends Resource

@export var id: int

## If [code]true[/code], you'll see speaker's face if setted on current frame in [member faces].
@export var use: bool = false:
	set(value):
		use = value
		if !use and faces.size() > 0: faces.clear()

## If [member use] is [code]true[/code] and setted for current [member id] and frame, shows speaker's face.
@export var faces: Array[CompressedTexture2D]:
	set(value): if use: faces = value
