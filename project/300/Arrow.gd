extends PathFollow2D


export(float) var speed = 144

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset += speed * delta
	if unit_offset >= 1:
		die()
		
func attack():
	return
	
func die():
	get_parent().queue_free()
