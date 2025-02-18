extends Node2D

var dest : Vector2 = Vector2.ZERO
var caster = null

@export var child : Node2D

func _setup(start_point : Vector2 = Vector2.ZERO, new_dest : Vector2 = Vector2.ZERO, new_owner = null):
	self.global_position = start_point
	dest = new_dest
	if new_owner != null:
		caster = new_owner
	_begin()

func _begin():
	child.rotation = child.global_position.angle_to_point(dest)
	var phase_tween = create_tween()
	phase_tween.tween_property(self, "modulate", Color(0., 0., 0., 0.), 1.5)
	phase_tween.tween_callback(func(): self.queue_free())
