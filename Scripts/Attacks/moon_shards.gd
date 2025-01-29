extends Node2D

var dest : Vector2 = Vector2.ZERO
var caster = null

@export var children : Array[PathFollow2D] = []

func _setup(start_point : Vector2 = Vector2.ZERO, new_dest : Vector2 = Vector2.ZERO, new_owner = null):
	self.global_position = start_point
	dest = new_dest
	if new_owner != null:
		caster = new_owner
	_begin()

func _begin():
	self.rotation = self.global_position.angle_to_point(dest) + deg_to_rad(90)
	$Trail2D.global_rotation = 0
	$Trail2D2.global_rotation = 0
	$Trail2D.global_position = Vector2.ZERO
	$Trail2D2.global_position = Vector2.ZERO
	for child in children:
		var tween = create_tween().set_parallel()
		tween.tween_property(child.get_child(0), "scale", Vector2(1., 1.), 1)
		tween.tween_property(child.get_child(1), "scale", Vector2(1., 1.), 1)
		tween.tween_property(child, 'progress_ratio', 1, 1)
		tween.chain().tween_callback(
			func(): 
			self.add_one()
			)

var counter : int = 0

func add_one():
	counter += 1
	if counter == 2:
		for child in children:
			child.visible = false
		$Target/CPUParticles2D.emitting = true
		$Target/Area2D/CollisionShape2D.disabled = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body != caster:
		body._damage(10)
	pass # Replace with function body.


func _on_gpu_particles_2d_finished() -> void:
	self.queue_free()
	pass # Replace with function body.


func _on_explosion_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body != caster:
		body._damage(30)
	pass # Replace with function body.
