extends PathFollow2D

export(float) var walk_speed = 0.04
export(float) var death_duration = 1.0
onready var timer = $DeathTimer
onready var alpha_mod = 0
var speed_scale = 10000
onready var time = get_tree().get_root().get_node("Game").time

# Called when the node enters the scene tree for the first time.
func _ready():
	walk_speed += pow(time,2)/speed_scale
	var rng = RandomNumberGenerator.new()
	rng.randomize()	
	walk_speed = rng.randf_range(0.8, 1.2)*walk_speed
	print(time," ",walk_speed)
	wiggle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	unit_offset += walk_speed * delta
	
	# alpha fade in/out on spawn/death
	if not timer.is_stopped(): # fade out on death
		alpha_mod -= delta/1.5
		$EnemySprite.modulate = Color(1.0,1.0,1.0,alpha_mod)
	elif alpha_mod < 1.0: # fade in
		alpha_mod += delta*walk_speed*4
		$EnemySprite.modulate = Color(1.0,1.0,1.0,alpha_mod)
	pass

func wiggle(max_x=3, max_y=3):
	$EnemySprite.translate(Vector2((randf()-0.5)*max_x*2, (randf()-0.5)*max_y*2))
	v_offset += (randf()-0.5) * 1

func attack():
	if $EnemySprite.animation != ('swipe'):
		$EnemySprite.play('swipe')
		walk_speed = 0

func die():
	# on play sound/anim on first death hit
	if timer.is_stopped():
		$EnemySprite.play('death')
		$DeathSound.play()
		walk_speed = 0
	else:
		return false
	timer.start(death_duration)
	yield(timer, "timeout")
	queue_free()
