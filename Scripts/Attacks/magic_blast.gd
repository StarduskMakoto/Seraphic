extends Node2D

var dest : Vector2 = Vector2.ZERO
var caster = null

@export var child : Node2D

func _setup(start_point : Vector2 = Vector2.ZERO, new_dest : Vector2 = Vector2.ZERO, new_owner = null):
	child.global_position = start_point
	dest = new_dest
	if new_owner != null:
		caster = new_owner
	_begin()

func _begin():
	child.rotation = child.global_position.angle_to_point(dest)
	child.scale = Vector2(0.3, 0.3)
	var tween = create_tween().set_parallel()
	tween.tween_property(child, "scale", Vector2(1., 1.), 1)
	tween.tween_property(child, 'global_position', dest, 1)
	tween.chain().tween_callback(
		func(): 
		self.queue_free()
		)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body != caster:
		body._damage(10)
	pass # Replace with function body.
