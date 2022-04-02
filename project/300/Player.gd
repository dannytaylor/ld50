extends PathFollow2D


export(Vector2) var movespeed = Vector2(8, 16)
var speed = -1
var direction = -1
onready var timer = $Timer
export(float) var attack_delay = 1
export(float) var attack_duration = 0.25
var cant_attack = false

onready var game = $"../../"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	reset_speed()

func reset_speed():
	direction *= -1
	speed = direction * ((randf() * (movespeed.y - movespeed.x)) + movespeed.x)

func attack():
	
	if cant_attack:
		return
	cant_attack = true
	
	#Spawn the sword and start a timer
	$Sword.monitoring = true
	$Sword.visible = true
	timer.start(attack_duration)
	yield(timer, "timeout")
	
	$Sword.monitoring = false
	$Sword.visible = false
	timer.start(attack_delay)
	yield(timer, "timeout")
	
	cant_attack = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
		offset += speed * delta
		if unit_offset >= 1 || unit_offset <= 0:
			reset_speed()
		
func _unhandled_key_input(event):
	if event.is_action_pressed("player_attack"):
		attack()


func _on_Sword_area_entered(area):
	print("Nice")
	game.score += 1
	area.get_parent().queue_free()
	
func _on_Hurtbox_area_entered(area):
	print("You died")
	game.playing = false
