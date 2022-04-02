extends Node2D

const EnemyScene = preload("Enemy.tscn")

onready var timer = $Timer
onready var path = $"../EnemyPath"
export(Vector2) var delay = Vector2(0.3, 1.5)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	spawn_enemy()
	
func spawn_enemy(repeat=true):
	
	var enemy = EnemyScene.instance()
	path.add_child(enemy)
	timer.start(randf()*(delay.y-delay.x)+delay.y)
	
	yield(timer, "timeout")
	if repeat:
		spawn_enemy()
