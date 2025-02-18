@tool
class_name Trail2D
extends Line2D

@export var LIFETIME : float = 2.
@export var DISTANCE : float = 5.
@export var MAX_POINTS : int = 5

class LinePoints:
	var pos : Vector2
	var lt : float
	
	func _init(new_pos : Vector2, lifet : float):
		pos = new_pos
		lt = lifet

var l_points : Array[LinePoints] = []

@export var TARGET : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func new_point():
	var new_l = LinePoints.new(TARGET.global_position, LIFETIME)
	l_points.append(new_l)

func draw_points():
	var new_points = []
	for i in l_points:
		new_points.append(i.pos)
	
	points = new_points

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if len(l_points) < 1:
		new_point()
	
	if l_points[-1].pos.distance_to(TARGET.global_position) > DISTANCE:
		new_point()
	
	if len(l_points) > MAX_POINTS:
		l_points.pop_at(0)
	
	var new_points : Array[LinePoints] = []
	for i in l_points:
		i.lt -= 0.1
		if i.lt > 0:
			new_points.append(i)
	l_points = new_points
	
	draw_points()
	pass
