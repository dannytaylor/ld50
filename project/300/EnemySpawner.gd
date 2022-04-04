extends Node2D

const EnemyScene = preload("Enemy.tscn")

onready var timer = $Timer
onready var path = $"../EnemyPath"
export(Vector2) var delay = Vector2(2.0, 5.0)
var delay_scale = 1.0
var delay_red = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	
	spawn_enemy()
	
func spawn_enemy(repeat=true):
	
	var enemy = EnemyScene.instance()
	path.add_child(enemy)
	timer.start((randf()*(delay.y-delay.x)+delay.y)/delay_scale)
	delay_scale = min(delay_scale + delay_red, 10.0) # max so it doesn't look too weird?
	
	yield(timer, "timeout")
	if repeat:
		spawn_enemy()
