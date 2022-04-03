extends PathFollow2D


export(Vector2) var movespeed = Vector2(4, 8)
var speed = -1
var direction = -1
onready var timer = $Timer

export(float) var max_stamina = 100
var stamina = max_stamina
var exhausted = false
export(float) var attack_windup = 0.15
export(float) var attack_duration = 0.35 # total including windup
export(float) var stamina_regen = 30  # Per second
export(float) var attack_cost = 35

export(float) var stamina_scale_max = 0.3 # max scale of stamina indicator texture
export(float) var stamina_alpha_max = 0.1

var attack_lock = Mutex.new()

export(float) var special_cost = 100
export(Vector2) var special_size = Vector2(1, 3)
export(float) var special_duration = 1

onready var game = $"../../"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	reset_speed()

func reset_speed():
	direction *= -1
	speed = direction * ((randf() * (movespeed.y - movespeed.x)) + movespeed.x)

func spend_stamina(amount):
	stamina = max(0, stamina-amount)
	if stamina == 0:
		exhausted = true

func attack():
	
	# Eat some stamina
	if exhausted:
		return
	
	$PlayerSprite.play("slice")
	
	spend_stamina(attack_cost)
	
	# Only let one thread handle the attack, but we can exteend it!
	if attack_lock.try_lock() == ERR_BUSY:
		timer.time_left = attack_duration
		return
	
	#Player the sword anim and start a timer
	$Sword/SwordSprite.play("slice")
	$Sword/SwordAudio.play()
	
	# don't activate the sword hitbox until after the wind up
	timer.start(attack_windup)
	yield(timer, "timeout")
	$Sword.monitoring = true
	timer.start(attack_duration - attack_windup)
	yield(timer, "timeout")

	
	
	# Attack is done
	$Sword.monitoring = false
	$Sword/SwordSprite.play("static_back")
	$PlayerSprite.play("idle")
	attack_lock.unlock()

func special():
	
	if exhausted:
		return
	
	spend_stamina(special_cost)
	
	$Special.monitoring = true
	$Special.visible = true
	$Special/Tween.interpolate_property($Special, "scale", Vector2(special_size.x, special_size.x), Vector2(special_size.y, special_size.y), special_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Special/Tween.start()
	yield($Special/Tween, "tween_all_completed")
	
	$Special.monitoring = false
	$Special.visible = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
		# Recover stamina
		stamina = min(stamina + stamina_regen*delta, max_stamina)
		if exhausted and stamina == max_stamina:
			exhausted = false
		
		# for stamina indicator appearance
		var stamina_scale = stamina_scale_max * stamina/max_stamina
		var stamina_alpha = stamina_alpha_max * stamina/max_stamina
		$StaminaIndicator.scale = Vector2(stamina_scale,stamina_scale)
		if exhausted:
			$StaminaIndicator.modulate = Color(0.922, 0.152, 0.246,0.2)
		else:
			$StaminaIndicator.modulate = Color(1.0,1.0,1.0,stamina_alpha)
		
		offset += speed * delta
		if unit_offset >= 1 || unit_offset <= 0:
			reset_speed()

func move_shield(event: InputEventMouseMotion):
	
	# Should should rotate around the player
	var angle = global_position.angle_to_point(event.position)
	if angle > -1.5708 and angle < 1.5708 :
		$Shield/ShieldSprite.flip_v = false
	else:
		$Shield/ShieldSprite.flip_v = true
	$Shield.rotation = angle

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		move_shield(event)
	elif event.is_action_pressed("player_attack"):
		attack()	
	elif event.is_action_pressed("player_special"):
		special()


func _on_Sword_area_entered(area):
	print("Nice")
	game.score += 1 # need to fix it so doesn't give extra point for hitting while dying
	area.get_parent().die()
	
func _on_Hurtbox_area_entered(area):
	print("You died")
	$PlayerSprite.play("death")
	game.playing = false


func _on_Special_area_entered(area):
	print("Nice special")
	game.score += 1
	area.get_parent().die()


func _on_Area2D_area_entered(area):
	print("Nice block")
	$PlayerSprite.play("block")
	$Shield/ShieldSprite.play("block")
	$Shield/ShieldSprite.frame = 0
	$Shield/ShieldAudio.play()
	game.score += 1
	area.get_parent().die()
	
func _on_PlayerSprite_animation_finished():
#	if $PlayerSprite.animation == "slice":
#		$PlayerSprite.play("idle")
	if $PlayerSprite.animation == "block":
		$PlayerSprite.play("idle")
