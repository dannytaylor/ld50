extends Node2D

var mouse_delta = Vector2.ZERO
var captureMouse = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.

# adapted from ld49
func _rotate_shield(delta):
	if mouse_delta == Vector2.ZERO:
		rotation_degrees = lerp(rotation_degrees, Vector2.ZERO, 0.01)
		return

	mouse_delta = Vector2.ZERO

func _input(event):
	
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		if not captureMouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			captureMouse = true
		
