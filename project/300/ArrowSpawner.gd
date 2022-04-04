extends Node2D

const ArrowScene = preload("Arrow.tscn")


export(Vector2) var spawn_delay = Vector2(0.5, 3)
var spawn_scale = 1.0

export(Vector2) var x_wiggle = Vector2(-50, 50)
export(Vector2) var y_wiggle = Vector2(0, 100)

onready var player = get_tree().get_nodes_in_group("player")[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	spawn_arrow()


func spawn_arrow(constant_only=false):
	
	#Pick a random node to spawn the arrow
	var nodes = $ConstantSources.get_children()
	if not constant_only:
		nodes.append_array(get_tree().get_nodes_in_group("enemy"))
	
	var index = randi() % len(nodes)
	var node = nodes[index]
	
	var new_path = $ArrowPathTemplate.duplicate()
	new_path.curve = new_path.curve.duplicate()
	add_child(new_path)
	
	# Wiggle the apex of the arc
	var target_position = Vector2(new_path.curve.get_point_position(1))
	target_position.x += rand_range(x_wiggle.x, x_wiggle.y)
	target_position.y += rand_range(y_wiggle.x, y_wiggle.y)
	
	if node.position.x > player.position.x:
		var movement = player.position.x - target_position.x
		target_position.x += movement
	
	new_path.curve.set_point_position(1, target_position)
	
	# Set start and end
	new_path.curve.set_point_position(0, node.global_position)
	new_path.curve.set_point_position(2, player.global_position)
	
	#Give it the arrow
	new_path.add_child(ArrowScene.instance())
	
	# Delay and spawn a new one
	$Timer.start(rand_range(spawn_delay.x/spawn_scale,spawn_delay.y/spawn_scale))
	spawn_scale += 0.025
	yield($Timer, "timeout")
	spawn_arrow()
