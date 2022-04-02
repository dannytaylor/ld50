extends PathFollow2D

export(float) var walk_speed = 0.03

# Called when the node enters the scene tree for the first time.
func _ready():
	wiggle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	unit_offset += walk_speed * delta
	pass

func wiggle(max_x=3, max_y=3):
	$Sprite.translate(Vector2((randf()-0.5)*max_x*2, (randf()-0.5)*max_y*2))
	v_offset += (randf()-0.5) * 1
