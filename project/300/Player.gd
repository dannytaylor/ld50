extends PathFollow2D

var dead = false
onready var gameovertimer = $GameOverTimer
export(float) var gameoverdelay = 2.0

export(Vector2) var movespeed = Vector2(4, 8)
var speed = -1
var direction = -1
onready var timer = $AttackTimer

export(float) var max_stamina = 100
var stamina = max_stamina
var exhausted = false
export(float) var attack_windup = 0.15
export(float) var attack_duration = 0.35 # total including windup
export(float) var stamina_regen = 30  # Per second
export(float) var attack_cost = 35

export(float) var stamina_scale_max = 0.15 # max scale of stamina indicator texture
export(float) var stamina_alpha_max = 0.1

var attack_lock = Mutex.new()

export(float) var special_cost = 100
export(Vector2) var special_size = Vector2(1, 3)
export(float) var special_duration = 1

onready var game = $"../../"
onready var gameover = get_tree().get_root().get_node("Game/UI/GameOver")

var captureMouse = false

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
		$ExhaustedAudio.play()
		$PlayerSprite.play("kneel")

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
	
	attack_lock.unlock()
	
	# if attack used up last of stamina
	if $PlayerSprite.animation != "kneel":
		$PlayerSprite.play("idle")
		
	if dead: # if died during the timers
		$PlayerSprite.play("death")
		
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
	
	if not dead:
		# Recover stamina
		stamina = min(stamina + stamina_regen*delta, max_stamina)
		if exhausted and stamina == max_stamina:
			$PlayerSprite.play("stand")
			exhausted = false
		
		# for stamina indicator appearance
		var stamina_scale = stamina_scale_max + stamina_scale_max * stamina/max_stamina
		var stamina_alpha = stamina_alpha_max * stamina/max_stamina
		$StaminaIndicator.scale = Vector2(stamina_scale,stamina_scale)
		if exhausted:
			$StaminaIndicator.modulate = Color(0.922, 0.152, 0.246,stamina_alpha_max*4)
		else:
			$StaminaIndicator.modulate = Color(1.0,1.0,1.0,stamina_alpha)
		
		offset += speed * delta
		if unit_offset >= 1 || unit_offset <= 0:
			reset_speed()
			
	# if dead
	else: # fade/move player items/ui
		$StaminaIndicator.modulate.a -= delta
		$Sword.modulate.a -= delta/3.0
		$Shield.modulate.a -= delta/3.0
		$Sword.position.y += delta*64
		$Shield.position.y += delta*64
		
		if gameovertimer.is_stopped():
			var ui_alpha = min(1.0,gameover.modulate.a+delta*4)
			gameover.modulate.a = ui_alpha

func move_shield(event: InputEventMouseMotion):
	
	# Should should rotate around the player
	var angle = global_position.angle_to_point(event.position)
	if angle > -1.5708 and angle < 1.5708 :
		$Shield/ShieldSprite.flip_v = false
	else:
		$Shield/ShieldSprite.flip_v = true
	$Shield.rotation = angle

func _unhandled_input(event):
	
	if not dead:
		if event is InputEventMouseMotion:
			move_shield(event)
		elif event.is_action_pressed("player_attack"):
			attack()	
		# disabling special temporarily - need to balance with regular attacks I think
		#elif event.is_action_pressed("player_special"):
		#	special()
	elif dead:
		if event is InputEventKey and event.scancode == KEY_X:
			get_tree().reload_current_scene()

func _on_Sword_area_entered(area):
	print("Nice")
	# only +1 on first hit, not on hitting while in death timer
	if area.get_parent().die():
		game.score += 1	
	
func _on_Hurtbox_area_entered(area):
	print("You died")
	area.get_parent().attack()
	if not dead:
		$PlayerSprite.play("death")
		$PlayerDeath.play()
		
		gameover.visible = true
		dead = true
		speed = 0
		game.playing = false
		
		gameovertimer.start(gameoverdelay)
		yield(gameovertimer, "timeout")
		


func _on_Special_area_entered(area):
	print("Nice special")
	
	# only +1 on first hit, not on hitting while in death timer
	if area.get_parent().die():
		game.score += 1	


func _on_Area2D_area_entered(area):
	print("Nice block")
	if not dead:
		$PlayerSprite.play("block")
		$Shield/ShieldSprite.play("block")
		$Shield/ShieldSprite.frame = 0
		$Shield/ShieldAudio.play()
		game.score += 1
		area.get_parent().die()
	
func _on_PlayerSprite_animation_finished():
	if not dead:
		if $PlayerSprite.animation == "block":
			$PlayerSprite.play("idle")
		elif $PlayerSprite.animation == "kneel":
			$PlayerSprite.play("exhausted")
		elif $PlayerSprite.animation == "stand":
			$PlayerSprite.play("idle")
	else:
		$PlayerSprite.play("death")
