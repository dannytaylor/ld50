extends Node2D

var score = 0
var time = 0
var playing = true

onready var score_label = get_node("UI/ScoreContainer/ScoreValue")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if playing:
		time += delta
		score_label.text = str(score)
	
