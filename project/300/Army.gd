extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var y_base = transform.origin.y
var time = randi()
export(float) var speed = 1.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	#Wiggle
	position.y = y_base + abs(sin(time)) * 5 * speed
	
	pass
